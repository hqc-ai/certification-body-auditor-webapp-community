-- NQA Auditor Webapp Community
-- PostgreSQL-compatible Phase 1 Community MVP reference schema.
-- This is a community architecture baseline, not a production migration plan.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE organizations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_code varchar(50) NOT NULL UNIQUE,
  legal_name varchar(255) NOT NULL,
  display_name varchar(255),
  country_code char(2),
  address_text text,
  website varchar(255),
  status varchar(30) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','INACTIVE','PROSPECT')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE sites (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE RESTRICT,
  site_code varchar(50) NOT NULL,
  site_name varchar(255) NOT NULL,
  address_text text,
  city varchar(120),
  country_code char(2),
  is_central_function boolean NOT NULL DEFAULT false,
  status varchar(30) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','INACTIVE')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (organization_id, site_code)
);

CREATE TABLE contacts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE RESTRICT,
  site_id uuid REFERENCES sites(id) ON DELETE RESTRICT,
  full_name varchar(255) NOT NULL,
  email varchar(255),
  phone varchar(80),
  job_title varchar(160),
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE standards (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code varchar(60) NOT NULL,
  name varchar(255) NOT NULL,
  version varchar(60),
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (code, version)
);

CREATE TABLE schemes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  scheme_code varchar(60) NOT NULL UNIQUE,
  scheme_name varchar(255) NOT NULL,
  standard_id uuid REFERENCES standards(id) ON DELETE RESTRICT,
  reporting_mode varchar(40),
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE certifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE RESTRICT,
  scheme_id uuid NOT NULL REFERENCES schemes(id) ON DELETE RESTRICT,
  certificate_reference varchar(120),
  initial_issue_date date,
  issue_date date,
  expiry_date date,
  status varchar(30) NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT','ACTIVE','SUSPENDED','EXPIRED','WITHDRAWN')),
  approved_scope text,
  proposed_scope text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE auditors (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  auditor_code varchar(50) NOT NULL UNIQUE,
  display_name varchar(255) NOT NULL,
  email varchar(255),
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE competencies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  auditor_id uuid NOT NULL REFERENCES auditors(id) ON DELETE RESTRICT,
  scheme_id uuid REFERENCES schemes(id) ON DELETE RESTRICT,
  competency_code varchar(80),
  role_code varchar(50),
  status varchar(30) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING','IN_PROGRESS','APPROVED','INACTIVE','EXPIRED')),
  valid_from date,
  valid_until date,
  evidence_reference text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE audit_projects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_code varchar(50) NOT NULL UNIQUE,
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE RESTRICT,
  status varchar(30) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','CLOSED')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE audits (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  audit_no varchar(50) NOT NULL UNIQUE,
  project_id uuid NOT NULL REFERENCES audit_projects(id) ON DELETE RESTRICT,
  audit_type varchar(50) NOT NULL,
  audit_stage varchar(50),
  status varchar(40) NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT','PLANNED','READY','IN_PROGRESS','READY_FOR_COMPLETION','COMPLETED','REPORTED')),
  start_date date NOT NULL,
  end_date date NOT NULL,
  planned_days numeric(6,2),
  actual_days numeric(6,2),
  is_integrated boolean NOT NULL DEFAULT false,
  is_unannounced boolean NOT NULL DEFAULT false,
  lead_auditor_id uuid REFERENCES auditors(id) ON DELETE RESTRICT,
  scope_text text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (end_date >= start_date)
);

CREATE TABLE audit_sites (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  audit_id uuid NOT NULL REFERENCES audits(id) ON DELETE RESTRICT,
  site_id uuid NOT NULL REFERENCES sites(id) ON DELETE RESTRICT,
  site_scope_text text,
  planned_days numeric(6,2),
  remote_ratio numeric(5,2) CHECK (remote_ratio IS NULL OR (remote_ratio >= 0 AND remote_ratio <= 100)),
  is_primary_site boolean NOT NULL DEFAULT false,
  status varchar(30) NOT NULL DEFAULT 'PLANNED' CHECK (status IN ('PLANNED','IN_PROGRESS','COMPLETED')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (audit_id, site_id)
);

CREATE TABLE audit_schemes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  audit_id uuid NOT NULL REFERENCES audits(id) ON DELETE RESTRICT,
  scheme_id uuid NOT NULL REFERENCES schemes(id) ON DELETE RESTRICT,
  certification_id uuid REFERENCES certifications(id) ON DELETE RESTRICT,
  scope_text text,
  status varchar(30),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (audit_id, scheme_id, certification_id)
);

CREATE TABLE audit_assignments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  audit_id uuid NOT NULL REFERENCES audits(id) ON DELETE RESTRICT,
  auditor_id uuid NOT NULL REFERENCES auditors(id) ON DELETE RESTRICT,
  site_id uuid REFERENCES sites(id) ON DELETE RESTRICT,
  scheme_id uuid REFERENCES schemes(id) ON DELETE RESTRICT,
  role varchar(50) NOT NULL,
  start_date date,
  end_date date,
  assigned_hours numeric(6,2),
  audit_days numeric(6,2),
  remote boolean NOT NULL DEFAULT false,
  is_team_lead boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date)
);

CREATE TABLE focus_areas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  audit_id uuid NOT NULL REFERENCES audits(id) ON DELETE RESTRICT,
  site_id uuid REFERENCES sites(id) ON DELETE RESTRICT,
  scheme_id uuid REFERENCES schemes(id) ON DELETE RESTRICT,
  name varchar(255) NOT NULL,
  description text,
  level_of_control smallint CHECK (level_of_control IS NULL OR (level_of_control BETWEEN 1 AND 5)),
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE findings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  audit_id uuid NOT NULL REFERENCES audits(id) ON DELETE RESTRICT,
  site_id uuid REFERENCES sites(id) ON DELETE RESTRICT,
  scheme_id uuid REFERENCES schemes(id) ON DELETE RESTRICT,
  focus_area_id uuid REFERENCES focus_areas(id) ON DELETE RESTRICT,
  finding_no varchar(50) NOT NULL,
  category varchar(40) NOT NULL CHECK (category IN ('MAJOR_NC','MINOR_NC','OBSERVATION','OFI','OTHER')),
  title varchar(255) NOT NULL,
  statement_text text NOT NULL,
  objective_evidence text,
  requirement_reference text,
  customer_process varchar(255),
  status varchar(40) NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT','OPEN','SHARED','RESPONSE_RECEIVED','UNDER_REVIEW','NEEDS_MORE_RESPONSE','ACCEPTED','CLOSED','REOPENED')),
  customer_visible boolean NOT NULL DEFAULT false,
  created_by uuid REFERENCES auditors(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  closed_at timestamptz,
  UNIQUE (audit_id, finding_no)
);

CREATE TABLE finding_responses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  finding_id uuid NOT NULL REFERENCES findings(id) ON DELETE RESTRICT,
  response_version integer NOT NULL,
  correction text,
  root_cause text,
  corrective_action text,
  customer_comment text,
  submitted_by_name varchar(255),
  submitted_at timestamptz,
  auditor_comment text,
  reviewed_by uuid REFERENCES auditors(id) ON DELETE RESTRICT,
  reviewed_at timestamptz,
  response_status varchar(30) NOT NULL DEFAULT 'DRAFT' CHECK (response_status IN ('DRAFT','SUBMITTED','ACCEPTED','NEEDS_MORE_RESPONSE','SUPERSEDED')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (finding_id, response_version)
);

CREATE TABLE finding_status_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  finding_id uuid NOT NULL REFERENCES findings(id) ON DELETE RESTRICT,
  from_status varchar(40),
  to_status varchar(40) NOT NULL,
  changed_by uuid REFERENCES auditors(id) ON DELETE RESTRICT,
  changed_at timestamptz NOT NULL DEFAULT now(),
  comment text
);

CREATE TABLE evidence (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  audit_id uuid NOT NULL REFERENCES audits(id) ON DELETE RESTRICT,
  finding_id uuid REFERENCES findings(id) ON DELETE RESTRICT,
  focus_area_id uuid REFERENCES focus_areas(id) ON DELETE RESTRICT,
  site_id uuid REFERENCES sites(id) ON DELETE RESTRICT,
  evidence_type varchar(50),
  title varchar(255) NOT NULL,
  description text,
  source_reference text,
  storage_key varchar(500),
  content_hash varchar(128),
  visibility varchar(30) NOT NULL DEFAULT 'INTERNAL' CHECK (visibility IN ('INTERNAL','AUDIT_TEAM','CUSTOMER')),
  created_by uuid REFERENCES auditors(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE management_summaries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  audit_id uuid NOT NULL REFERENCES audits(id) ON DELETE RESTRICT,
  focus_area_id uuid REFERENCES focus_areas(id) ON DELETE RESTRICT,
  site_id uuid REFERENCES sites(id) ON DELETE RESTRICT,
  positive_indications text,
  main_areas_for_improvement text,
  other_summary text,
  level_of_control smallint CHECK (level_of_control IS NULL OR (level_of_control BETWEEN 1 AND 5)),
  customer_visible boolean NOT NULL DEFAULT false,
  created_by uuid REFERENCES auditors(id) ON DELETE RESTRICT,
  updated_by uuid REFERENCES auditors(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE conclusions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  audit_id uuid NOT NULL UNIQUE REFERENCES audits(id) ON DELETE RESTRICT,
  conclusion_text text NOT NULL,
  recommendation text,
  follow_up_required boolean NOT NULL DEFAULT false,
  customer_visible boolean NOT NULL DEFAULT false,
  created_by uuid REFERENCES auditors(id) ON DELETE RESTRICT,
  updated_by uuid REFERENCES auditors(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE statements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  audit_id uuid NOT NULL REFERENCES audits(id) ON DELETE RESTRICT,
  topic_code varchar(80) NOT NULL,
  topic_title varchar(255) NOT NULL,
  assessment_state varchar(30) NOT NULL DEFAULT 'ASSESSED' CHECK (assessment_state IN ('ASSESSED','NOT_APPLICABLE','NOT_ASSESSED')),
  selected_statement text,
  final_text text,
  rating smallint,
  customer_visible boolean NOT NULL DEFAULT false,
  sort_order integer NOT NULL DEFAULT 0,
  created_by uuid REFERENCES auditors(id) ON DELETE RESTRICT,
  updated_by uuid REFERENCES auditors(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (audit_id, topic_code)
);

CREATE TABLE audit_documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  audit_id uuid NOT NULL REFERENCES audits(id) ON DELETE RESTRICT,
  finding_id uuid REFERENCES findings(id) ON DELETE RESTRICT,
  evidence_id uuid REFERENCES evidence(id) ON DELETE RESTRICT,
  category varchar(60) NOT NULL,
  file_name varchar(255) NOT NULL,
  mime_type varchar(120),
  storage_key varchar(500) NOT NULL UNIQUE,
  visibility varchar(30) NOT NULL DEFAULT 'INTERNAL' CHECK (visibility IN ('INTERNAL','AUDIT_TEAM','CUSTOMER')),
  version_no integer NOT NULL DEFAULT 1,
  created_by uuid REFERENCES auditors(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE audit_reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  audit_id uuid NOT NULL REFERENCES audits(id) ON DELETE RESTRICT,
  document_id uuid REFERENCES audit_documents(id) ON DELETE RESTRICT,
  report_type varchar(60) NOT NULL,
  report_status varchar(30) NOT NULL DEFAULT 'DRAFT' CHECK (report_status IN ('DRAFT','FINAL','RELEASED','SUPERSEDED')),
  template_name varchar(120),
  template_version varchar(60),
  source_revision varchar(128),
  generated_by uuid REFERENCES auditors(id) ON DELETE RESTRICT,
  generated_at timestamptz NOT NULL DEFAULT now(),
  released_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE technical_reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  audit_id uuid NOT NULL REFERENCES audits(id) ON DELETE RESTRICT,
  reviewer_id uuid REFERENCES auditors(id) ON DELETE RESTRICT,
  status varchar(30) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING','IN_REVIEW','REVERTED','REVIEWED','CLOSED')),
  result varchar(80),
  comments text,
  started_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE audit_status_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  audit_id uuid NOT NULL REFERENCES audits(id) ON DELETE RESTRICT,
  from_status varchar(40),
  to_status varchar(40) NOT NULL,
  changed_by uuid REFERENCES auditors(id) ON DELETE RESTRICT,
  changed_at timestamptz NOT NULL DEFAULT now(),
  comment text
);

CREATE INDEX idx_sites_organization ON sites(organization_id);
CREATE INDEX idx_audits_project_status_dates ON audits(project_id, status, start_date, end_date);
CREATE INDEX idx_audit_sites_audit ON audit_sites(audit_id);
CREATE INDEX idx_audit_schemes_audit ON audit_schemes(audit_id);
CREATE INDEX idx_audit_assignments_audit_auditor ON audit_assignments(audit_id, auditor_id);
CREATE INDEX idx_focus_areas_audit ON focus_areas(audit_id);
CREATE INDEX idx_findings_audit_status ON findings(audit_id, status);
CREATE INDEX idx_findings_context ON findings(site_id, scheme_id, focus_area_id);
CREATE INDEX idx_finding_responses_finding ON finding_responses(finding_id, response_version);
CREATE INDEX idx_evidence_audit_finding ON evidence(audit_id, finding_id);
CREATE INDEX idx_reports_audit_status ON audit_reports(audit_id, report_status);
CREATE INDEX idx_technical_reviews_audit_status ON technical_reviews(audit_id, status);
CREATE INDEX idx_audit_status_history_audit_time ON audit_status_history(audit_id, changed_at);
