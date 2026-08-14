-- CB Auditor Webapp Community
-- Phase 1D Customer Portal reference extension.
-- Community architecture baseline: 14 August 2026.
--
-- Apply after:
--   1) database/schema.sql
--   2) database/phase-1c-extension.sql
--
-- This script is architecture-oriented reference SQL, not a production migration plan.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================
-- 1. Customer-facing service aggregation
-- ============================================================

CREATE TABLE IF NOT EXISTS service_engagements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE RESTRICT,
  scheme_id uuid NOT NULL REFERENCES schemes(id) ON DELETE RESTRICT,
  certification_id uuid REFERENCES certifications(id) ON DELETE RESTRICT,
  service_code varchar(80) NOT NULL,
  display_name varchar(255),
  status varchar(30) NOT NULL DEFAULT 'ACTIVE'
    CHECK (status IN ('PLANNED','ACTIVE','SUSPENDED','CLOSED','CANCELLED')),
  valid_from date,
  valid_until date,
  external_reference varchar(160),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (organization_id, service_code),
  CHECK (valid_until IS NULL OR valid_from IS NULL OR valid_until >= valid_from)
);

CREATE INDEX IF NOT EXISTS idx_service_engagements_org_status
  ON service_engagements(organization_id, status, scheme_id);

CREATE TABLE IF NOT EXISTS service_engagement_sites (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  service_engagement_id uuid NOT NULL REFERENCES service_engagements(id) ON DELETE RESTRICT,
  site_id uuid NOT NULL REFERENCES sites(id) ON DELETE RESTRICT,
  status varchar(30) NOT NULL DEFAULT 'ACTIVE'
    CHECK (status IN ('ACTIVE','INACTIVE')),
  valid_from date,
  valid_until date,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (service_engagement_id, site_id),
  CHECK (valid_until IS NULL OR valid_from IS NULL OR valid_until >= valid_from)
);

CREATE INDEX IF NOT EXISTS idx_service_engagement_sites_site
  ON service_engagement_sites(site_id, status);

-- ============================================================
-- 2. Service / certification cycles
-- ============================================================

CREATE TABLE IF NOT EXISTS service_cycles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  service_engagement_id uuid NOT NULL REFERENCES service_engagements(id) ON DELETE RESTRICT,
  cycle_label varchar(120) NOT NULL,
  cycle_year integer,
  start_date date,
  end_date date,
  status varchar(30) NOT NULL DEFAULT 'ACTIVE'
    CHECK (status IN ('PLANNED','ACTIVE','COMPLETED','CANCELLED')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (service_engagement_id, cycle_label),
  CHECK (cycle_year IS NULL OR cycle_year BETWEEN 1900 AND 2200),
  CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date)
);

CREATE INDEX IF NOT EXISTS idx_service_cycles_engagement_year
  ON service_cycles(service_engagement_id, cycle_year, status);

CREATE TABLE IF NOT EXISTS audit_service_cycles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  audit_id uuid NOT NULL REFERENCES audits(id) ON DELETE RESTRICT,
  service_cycle_id uuid NOT NULL REFERENCES service_cycles(id) ON DELETE RESTRICT,
  scheme_id uuid REFERENCES schemes(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (audit_id, service_cycle_id, scheme_id)
);

CREATE INDEX IF NOT EXISTS idx_audit_service_cycles_cycle
  ON audit_service_cycles(service_cycle_id, audit_id);

-- ============================================================
-- 3. Customer-visible schedule lifecycle
-- ============================================================

CREATE TABLE IF NOT EXISTS audit_schedule_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE RESTRICT,
  service_engagement_id uuid REFERENCES service_engagements(id) ON DELETE RESTRICT,
  service_cycle_id uuid REFERENCES service_cycles(id) ON DELETE RESTRICT,
  audit_id uuid REFERENCES audits(id) ON DELETE RESTRICT,
  site_id uuid REFERENCES sites(id) ON DELETE RESTRICT,
  event_type varchar(40) NOT NULL DEFAULT 'AUDIT'
    CHECK (event_type IN ('AUDIT','FOLLOW_UP','SPECIAL','OTHER')),
  status varchar(40) NOT NULL DEFAULT 'PROPOSED'
    CHECK (status IN (
      'PROPOSED','NOT_CONFIRMED','CONFIRMED','RESCHEDULE_REQUESTED',
      'CANCELLED','COMPLETED'
    )),
  starts_at timestamptz NOT NULL,
  ends_at timestamptz,
  customer_visible boolean NOT NULL DEFAULT true,
  customer_note text,
  internal_reference varchar(160),
  created_by uuid REFERENCES users(id) ON DELETE RESTRICT,
  updated_by uuid REFERENCES users(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (ends_at IS NULL OR ends_at >= starts_at)
);

CREATE INDEX IF NOT EXISTS idx_audit_schedule_events_org_time
  ON audit_schedule_events(organization_id, starts_at, status);

CREATE INDEX IF NOT EXISTS idx_audit_schedule_events_service_time
  ON audit_schedule_events(service_engagement_id, starts_at, status)
  WHERE service_engagement_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_audit_schedule_events_audit
  ON audit_schedule_events(audit_id)
  WHERE audit_id IS NOT NULL;

-- ============================================================
-- 4. Narrower customer portal access scopes
-- ============================================================

CREATE TABLE IF NOT EXISTS customer_portal_site_access (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  portal_access_id uuid NOT NULL REFERENCES customer_portal_access(id) ON DELETE CASCADE,
  site_id uuid NOT NULL REFERENCES sites(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (portal_access_id, site_id)
);

CREATE INDEX IF NOT EXISTS idx_customer_portal_site_access_site
  ON customer_portal_site_access(site_id, portal_access_id);

CREATE TABLE IF NOT EXISTS customer_portal_service_access (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  portal_access_id uuid NOT NULL REFERENCES customer_portal_access(id) ON DELETE CASCADE,
  service_engagement_id uuid NOT NULL REFERENCES service_engagements(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (portal_access_id, service_engagement_id)
);

CREATE INDEX IF NOT EXISTS idx_customer_portal_service_access_service
  ON customer_portal_service_access(service_engagement_id, portal_access_id);

-- ============================================================
-- 5. Customer dashboard preferences
-- ============================================================

CREATE TABLE IF NOT EXISTS portal_dashboard_preferences (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  preference_key varchar(80) NOT NULL DEFAULT 'DEFAULT',
  selected_organization_id uuid REFERENCES organizations(id) ON DELETE SET NULL,
  selected_service_engagement_id uuid REFERENCES service_engagements(id) ON DELETE SET NULL,
  selected_site_id uuid REFERENCES sites(id) ON DELETE SET NULL,
  selected_year integer,
  filter_state jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, preference_key),
  CHECK (selected_year IS NULL OR selected_year BETWEEN 1900 AND 2200)
);

CREATE INDEX IF NOT EXISTS idx_portal_dashboard_preferences_user
  ON portal_dashboard_preferences(user_id);

-- ============================================================
-- 6. Portal activity / material customer action trace
-- ============================================================

CREATE TABLE IF NOT EXISTS portal_activity_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id) ON DELETE RESTRICT,
  organization_id uuid REFERENCES organizations(id) ON DELETE RESTRICT,
  action_code varchar(100) NOT NULL,
  resource_type varchar(80),
  resource_id uuid,
  outcome varchar(30) NOT NULL DEFAULT 'SUCCESS'
    CHECK (outcome IN ('SUCCESS','DENIED','FAILED')),
  source_ip inet,
  user_agent_hash varchar(128),
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  occurred_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_portal_activity_user_time
  ON portal_activity_log(user_id, occurred_at DESC);

CREATE INDEX IF NOT EXISTS idx_portal_activity_org_time
  ON portal_activity_log(organization_id, occurred_at DESC);

CREATE INDEX IF NOT EXISTS idx_portal_activity_resource
  ON portal_activity_log(resource_type, resource_id, occurred_at DESC)
  WHERE resource_id IS NOT NULL;

-- ============================================================
-- 7. Optional linkage for certificate/customer portal publication
-- ============================================================
--
-- Certificate metadata already exists in certifications.
-- Customer-visible certificate documents should continue to use
-- audit_documents + document_publications from Phase 1C.
-- No duplicate certificate table is created here.

-- ============================================================
-- 8. Reference comments for implementers
-- ============================================================

COMMENT ON TABLE service_engagements IS
  'Phase 1D customer-facing service identity; not a commercial contract ledger.';

COMMENT ON TABLE service_cycles IS
  'Year/cycle grouping used by customer portal service history and progress projections.';

COMMENT ON TABLE audit_schedule_events IS
  'Customer scheduling lifecycle kept separate from audit execution status.';

COMMENT ON TABLE customer_portal_site_access IS
  'Optional site allow-list that narrows an existing customer_portal_access grant.';

COMMENT ON TABLE customer_portal_service_access IS
  'Optional service allow-list that narrows an existing customer_portal_access grant.';

COMMENT ON TABLE portal_dashboard_preferences IS
  'Presentation preferences only; never use as authorization evidence.';

COMMENT ON TABLE portal_activity_log IS
  'Material customer portal action trace; not a replacement for identity-provider security logs.';

