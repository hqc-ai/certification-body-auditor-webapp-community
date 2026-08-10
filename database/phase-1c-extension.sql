-- CB Auditor Webapp Community
-- Phase 1C reference extension for an existing Phase 1A/1B PostgreSQL schema.
-- Community architecture baseline; review before production migration.
--
-- Expected existing tables include:
-- organizations, contacts, auditors, audits, findings, audit_documents,
-- technical_reviews, audit_status_history, finding_status_history.
--
-- This script intentionally uses generic Certification Body terminology.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================
-- 1. Identity and global roles
-- ============================================================

CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email varchar(255) UNIQUE,
  display_name varchar(255) NOT NULL,
  user_type varchar(30) NOT NULL
    CHECK (user_type IN ('INTERNAL','EXTERNAL','SERVICE')),
  status varchar(30) NOT NULL DEFAULT 'ACTIVE'
    CHECK (status IN ('INVITED','ACTIVE','INACTIVE','SUSPENDED')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code varchar(80) NOT NULL UNIQUE,
  name varchar(160) NOT NULL,
  description text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO roles (code, name, description)
VALUES
  ('AUDITOR', 'Auditor', 'Audit execution and customer corrective-action review'),
  ('REVIEWER', 'Reviewer', 'Independent technical review'),
  ('CERTIFICATION_DECISION', 'Certification Decision', 'Independent certification decision'),
  ('PLANNER', 'Planner / Audit Coordinator', 'Scheduling, coordination, publication and reminders'),
  ('CB_ADMIN', 'CB Administrator', 'User, role and configuration administration'),
  ('CUSTOMER', 'Customer Representative', 'Restricted customer portal user')
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  role_id uuid NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
  valid_from timestamptz,
  valid_to timestamptz,
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, role_id)
);

-- Optional bridge from the existing auditor master to the generalized user identity.
ALTER TABLE auditors
  ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES users(id) ON DELETE RESTRICT;

CREATE UNIQUE INDEX IF NOT EXISTS uq_auditors_user_id
  ON auditors(user_id)
  WHERE user_id IS NOT NULL;

-- ============================================================
-- 2. Audit-specific operational assignments
-- ============================================================

CREATE TABLE IF NOT EXISTS audit_role_assignments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  audit_id uuid NOT NULL REFERENCES audits(id) ON DELETE RESTRICT,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  role_code varchar(80) NOT NULL
    CHECK (role_code IN ('AUDITOR','REVIEWER','CERTIFICATION_DECISION','PLANNER')),
  is_lead boolean NOT NULL DEFAULT false,
  status varchar(30) NOT NULL DEFAULT 'ASSIGNED'
    CHECK (status IN ('ASSIGNED','ACTIVE','REMOVED','COMPLETED')),
  assigned_by uuid REFERENCES users(id) ON DELETE RESTRICT,
  assigned_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_audit_role_assignments_audit
  ON audit_role_assignments(audit_id, role_code, status);

CREATE INDEX IF NOT EXISTS idx_audit_role_assignments_user
  ON audit_role_assignments(user_id, status);

-- ============================================================
-- 3. Customer portal identity/access
-- ============================================================

ALTER TABLE contacts
  ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES users(id) ON DELETE RESTRICT;

CREATE TABLE IF NOT EXISTS customer_portal_access (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  contact_id uuid REFERENCES contacts(id) ON DELETE RESTRICT,
  user_id uuid REFERENCES users(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE RESTRICT,
  audit_id uuid REFERENCES audits(id) ON DELETE RESTRICT,
  access_status varchar(30) NOT NULL DEFAULT 'INVITED'
    CHECK (access_status IN ('INVITED','ACTIVE','REVOKED','EXPIRED')),
  invited_at timestamptz,
  activated_at timestamptz,
  revoked_at timestamptz,
  expires_at timestamptz,
  created_by uuid REFERENCES users(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (contact_id IS NOT NULL OR user_id IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS idx_customer_portal_access_scope
  ON customer_portal_access(organization_id, audit_id, access_status);

CREATE INDEX IF NOT EXISTS idx_customer_portal_access_user
  ON customer_portal_access(user_id, access_status);

-- ============================================================
-- 4. Audit workflow states
-- ============================================================

ALTER TABLE audits DROP CONSTRAINT IF EXISTS audits_status_check;

ALTER TABLE audits
  ADD CONSTRAINT audits_status_check
  CHECK (status IN (
    -- legacy Phase 1A/1B values allowed during migration
    'DRAFT','READY_FOR_COMPLETION','COMPLETED','REPORTED',
    -- Phase 1C normalized values
    'PLANNED','READY','IN_PROGRESS','AUDIT_COMPLETED',
    'REPORT_PREPARATION','SUBMITTED_FOR_REVIEW',
    'REVERTED_TO_AUDITOR','TECHNICAL_REVIEW_ACCEPTED',
    'AWAITING_CERTIFICATION_DECISION','CERTIFICATION_RETURNED',
    'CERTIFICATION_HOLD','CERTIFICATION_APPROVED',
    'CERTIFICATE_ISSUED','PUBLISHED_TO_CUSTOMER','CLOSED'
  ));

-- ============================================================
-- 5. Technical review extension
-- ============================================================

ALTER TABLE technical_reviews
  ADD COLUMN IF NOT EXISTS reviewer_user_id uuid REFERENCES users(id) ON DELETE RESTRICT,
  ADD COLUMN IF NOT EXISTS revision_no integer NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS submitted_at timestamptz,
  ADD COLUMN IF NOT EXISTS review_summary text;

-- Normalize old status names when present.
UPDATE technical_reviews SET status = 'IN_PROGRESS' WHERE status = 'IN_REVIEW';
UPDATE technical_reviews SET status = 'RETURNED' WHERE status = 'REVERTED';
UPDATE technical_reviews SET status = 'ACCEPTED' WHERE status = 'REVIEWED';

ALTER TABLE technical_reviews DROP CONSTRAINT IF EXISTS technical_reviews_status_check;

ALTER TABLE technical_reviews
  ADD CONSTRAINT technical_reviews_status_check
  CHECK (status IN ('PENDING','IN_PROGRESS','RETURNED','ACCEPTED','CLOSED'));

CREATE INDEX IF NOT EXISTS idx_technical_reviews_reviewer_queue
  ON technical_reviews(reviewer_user_id, status, created_at);

CREATE TABLE IF NOT EXISTS technical_review_actions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  review_id uuid NOT NULL REFERENCES technical_reviews(id) ON DELETE RESTRICT,
  action_type varchar(40) NOT NULL
    CHECK (action_type IN ('COMMENT','RETURN','ACCEPT','CHECKLIST_UPDATE')),
  section_code varchar(80),
  comment text,
  created_by uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (action_type <> 'RETURN' OR (comment IS NOT NULL AND length(trim(comment)) > 0))
);

CREATE INDEX IF NOT EXISTS idx_technical_review_actions_review
  ON technical_review_actions(review_id, created_at);

CREATE TABLE IF NOT EXISTS review_checklist_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  item_code varchar(80) NOT NULL UNIQUE,
  title varchar(255) NOT NULL,
  description text,
  mandatory boolean NOT NULL DEFAULT true,
  active boolean NOT NULL DEFAULT true,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO review_checklist_items (item_code, title, sort_order)
VALUES
  ('SCOPE_VERIFIED', 'Audit scope verified', 10),
  ('DURATION_ACCEPTABLE', 'Audit duration acceptable', 20),
  ('TEAM_COMPETENCE', 'Audit team / competence acceptable', 30),
  ('PLAN_CONSISTENT', 'Audit plan available and consistent', 40),
  ('FINDINGS_SUPPORTED', 'Findings correctly classified and supported by evidence', 50),
  ('CONCLUSIONS_CONSISTENT', 'Conclusions consistent with audit evidence', 60),
  ('RECOMMENDATION_JUSTIFIED', 'Certification recommendation justified', 70),
  ('DOCUMENTS_PRESENT', 'Required documents present', 80)
ON CONFLICT (item_code) DO NOTHING;

CREATE TABLE IF NOT EXISTS review_checklist_responses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  review_id uuid NOT NULL REFERENCES technical_reviews(id) ON DELETE RESTRICT,
  checklist_item_id uuid NOT NULL REFERENCES review_checklist_items(id) ON DELETE RESTRICT,
  response varchar(30) NOT NULL
    CHECK (response IN ('YES','NO','NOT_APPLICABLE','NOT_REVIEWED')),
  comment text,
  reviewed_by uuid REFERENCES users(id) ON DELETE RESTRICT,
  reviewed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (review_id, checklist_item_id)
);

-- ============================================================
-- 6. Certification decision
-- ============================================================

CREATE TABLE IF NOT EXISTS certification_decisions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  audit_id uuid NOT NULL REFERENCES audits(id) ON DELETE RESTRICT,
  technical_review_id uuid NOT NULL REFERENCES technical_reviews(id) ON DELETE RESTRICT,
  decision_maker_user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  status varchar(30) NOT NULL DEFAULT 'PENDING'
    CHECK (status IN ('PENDING','APPROVED','RETURNED','HOLD','REJECTED')),
  decision_type varchar(30)
    CHECK (decision_type IS NULL OR decision_type IN ('GRANT','MAINTAIN','RENEW','EXTEND','REDUCE','OTHER')),
  decision_comment text,
  decided_at timestamptz,
  revision_no integer NOT NULL DEFAULT 1 CHECK (revision_no > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (audit_id, revision_no)
);

CREATE INDEX IF NOT EXISTS idx_certification_decisions_queue
  ON certification_decisions(decision_maker_user_id, status, created_at);

-- ============================================================
-- 7. Finding/customer response extension
-- ============================================================

ALTER TABLE findings
  ADD COLUMN IF NOT EXISTS customer_response_due_date date,
  ADD COLUMN IF NOT EXISTS customer_response_status varchar(40),
  ADD COLUMN IF NOT EXISTS closed_by_user_id uuid REFERENCES users(id) ON DELETE RESTRICT;

ALTER TABLE findings DROP CONSTRAINT IF EXISTS findings_status_check;

ALTER TABLE findings
  ADD CONSTRAINT findings_status_check
  CHECK (status IN (
    -- legacy Phase 1A/1B values
    'DRAFT','OPEN','SHARED','RESPONSE_RECEIVED','UNDER_REVIEW',
    'NEEDS_MORE_RESPONSE','ACCEPTED','CLOSED','REOPENED',
    -- Phase 1C workflow values
    'AWAITING_CUSTOMER_RESPONSE','CUSTOMER_RESPONSE_SUBMITTED',
    'UNDER_AUDITOR_REVIEW','REVERTED_TO_CUSTOMER',
    'EFFECTIVENESS_VERIFIED'
  ));

CREATE INDEX IF NOT EXISTS idx_findings_customer_due
  ON findings(customer_response_due_date, status)
  WHERE customer_response_due_date IS NOT NULL;

CREATE TABLE IF NOT EXISTS finding_customer_responses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  finding_id uuid NOT NULL REFERENCES findings(id) ON DELETE RESTRICT,
  customer_user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  version_no integer NOT NULL CHECK (version_no > 0),
  correction text,
  root_cause text,
  corrective_action text,
  status varchar(30) NOT NULL DEFAULT 'DRAFT'
    CHECK (status IN ('DRAFT','SUBMITTED','REVERTED','ACCEPTED')),
  submitted_at timestamptz,
  reviewed_by uuid REFERENCES users(id) ON DELETE RESTRICT,
  reviewed_at timestamptz,
  auditor_comment text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (finding_id, version_no)
);

CREATE INDEX IF NOT EXISTS idx_finding_customer_responses_finding
  ON finding_customer_responses(finding_id, version_no DESC);

CREATE TABLE IF NOT EXISTS response_evidence (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  response_id uuid NOT NULL REFERENCES finding_customer_responses(id) ON DELETE RESTRICT,
  document_id uuid NOT NULL REFERENCES audit_documents(id) ON DELETE RESTRICT,
  uploaded_by uuid REFERENCES users(id) ON DELETE RESTRICT,
  uploaded_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (response_id, document_id)
);

-- ============================================================
-- 8. Controlled document publication
-- ============================================================

CREATE TABLE IF NOT EXISTS document_publications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id uuid NOT NULL REFERENCES audit_documents(id) ON DELETE RESTRICT,
  audit_id uuid NOT NULL REFERENCES audits(id) ON DELETE RESTRICT,
  audience varchar(30) NOT NULL
    CHECK (audience IN ('CUSTOMER','AUDIT_TEAM','INTERNAL_CB')),
  status varchar(30) NOT NULL
    CHECK (status IN ('PUBLISHED','WITHDRAWN')),
  published_by uuid REFERENCES users(id) ON DELETE RESTRICT,
  published_at timestamptz,
  withdrawn_by uuid REFERENCES users(id) ON DELETE RESTRICT,
  withdrawn_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (
    (status = 'PUBLISHED' AND published_at IS NOT NULL)
    OR
    (status = 'WITHDRAWN' AND withdrawn_at IS NOT NULL)
  )
);

CREATE INDEX IF NOT EXISTS idx_document_publications_customer
  ON document_publications(audit_id, audience, status);

-- ============================================================
-- 9. Notifications and reminders
-- ============================================================

CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  event_type varchar(80) NOT NULL,
  title varchar(255) NOT NULL,
  body text,
  related_entity_type varchar(80),
  related_entity_id uuid,
  read_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_unread
  ON notifications(user_id, created_at DESC)
  WHERE read_at IS NULL;

CREATE TABLE IF NOT EXISTS reminders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  audit_id uuid REFERENCES audits(id) ON DELETE RESTRICT,
  finding_id uuid REFERENCES findings(id) ON DELETE RESTRICT,
  recipient_user_id uuid REFERENCES users(id) ON DELETE RESTRICT,
  recipient_email varchar(255),
  reminder_type varchar(80) NOT NULL,
  due_at timestamptz,
  sent_at timestamptz,
  status varchar(30) NOT NULL DEFAULT 'OPEN'
    CHECK (status IN ('OPEN','SENT','CANCELLED','COMPLETED')),
  created_by uuid REFERENCES users(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (audit_id IS NOT NULL OR finding_id IS NOT NULL),
  CHECK (recipient_user_id IS NOT NULL OR recipient_email IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS idx_reminders_due
  ON reminders(status, due_at)
  WHERE due_at IS NOT NULL;

-- ============================================================
-- 10. Generic access history (optional but useful for portal)
-- ============================================================

CREATE TABLE IF NOT EXISTS access_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  portal_access_id uuid NOT NULL REFERENCES customer_portal_access(id) ON DELETE RESTRICT,
  from_status varchar(30),
  to_status varchar(30) NOT NULL,
  actor_user_id uuid REFERENCES users(id) ON DELETE RESTRICT,
  comment text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_access_history_access_time
  ON access_history(portal_access_id, created_at);

-- ============================================================
-- 11. Suggested Community projections
-- ============================================================

CREATE OR REPLACE VIEW review_queue_v AS
SELECT
  tr.id AS review_id,
  tr.audit_id,
  tr.reviewer_user_id,
  tr.status,
  tr.revision_no,
  tr.submitted_at,
  tr.started_at,
  tr.completed_at,
  tr.created_at
FROM technical_reviews tr
WHERE tr.status IN ('PENDING','IN_PROGRESS','RETURNED');

CREATE OR REPLACE VIEW decision_queue_v AS
SELECT
  cd.id AS decision_id,
  cd.audit_id,
  cd.technical_review_id,
  cd.decision_maker_user_id,
  cd.status,
  cd.decision_type,
  cd.created_at
FROM certification_decisions cd
JOIN technical_reviews tr ON tr.id = cd.technical_review_id
WHERE tr.status = 'ACCEPTED'
  AND cd.status IN ('PENDING','RETURNED','HOLD');

CREATE OR REPLACE VIEW open_customer_actions_v AS
SELECT
  f.id AS finding_id,
  f.audit_id,
  f.finding_no,
  f.title,
  f.status,
  f.customer_response_due_date
FROM findings f
WHERE f.status IN (
  'AWAITING_CUSTOMER_RESPONSE',
  'REVERTED_TO_CUSTOMER',
  'CUSTOMER_RESPONSE_SUBMITTED',
  'UNDER_AUDITOR_REVIEW'
);

CREATE OR REPLACE VIEW customer_portal_documents_v AS
SELECT
  dp.id AS publication_id,
  dp.audit_id,
  dp.document_id,
  dp.published_at,
  ad.file_name,
  ad.category,
  ad.mime_type,
  ad.storage_key
FROM document_publications dp
JOIN audit_documents ad ON ad.id = dp.document_id
WHERE dp.audience = 'CUSTOMER'
  AND dp.status = 'PUBLISHED';

-- ============================================================
-- 12. Integrity notes that require service-layer enforcement
-- ============================================================
--
-- The following rules depend on cross-row/context checks and should be
-- enforced transactionally in the application/domain service:
--
-- 1. Reviewer must hold REVIEWER global role and active audit assignment.
-- 2. Decision maker must hold CERTIFICATION_DECISION role and active assignment.
-- 3. Reviewer cannot accept until mandatory checklist items are complete.
-- 4. Certification Decision cannot become APPROVED unless the referenced
--    technical review is ACCEPTED.
-- 5. Customer Portal queries require active customer_portal_access with
--    organization/audit scope match.
-- 6. Planner cannot accept or close findings.
-- 7. Every workflow state transition must append history in the same transaction.
-- 8. Customer document access requires both authorization and active CUSTOMER publication.
