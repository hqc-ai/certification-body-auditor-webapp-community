-- Demo-only seed data. Contains fictional organizations and identifiers.
-- Safe for Community Edition examples; replace for local development as needed.

INSERT INTO standards (id, code, name, version) VALUES
('10000000-0000-0000-0000-000000000001','ISO27001','Information security management systems','2022'),
('10000000-0000-0000-0000-000000000002','ISO42001','Artificial intelligence management system','2023');

INSERT INTO schemes (id, scheme_code, scheme_name, standard_id, reporting_mode) VALUES
('20000000-0000-0000-0000-000000000001','COMM-ISMS','Community ISMS Assessment','10000000-0000-0000-0000-000000000001','FULL'),
('20000000-0000-0000-0000-000000000002','COMM-AIMS','Community AIMS Assessment','10000000-0000-0000-0000-000000000002','FULL');

INSERT INTO organizations (id, organization_code, legal_name, display_name, country_code, address_text) VALUES
('30000000-0000-0000-0000-000000000001','DEMO-ORG-001','Example Manufacturing Organization','Example Manufacturing','VN','Fictional demo address');

INSERT INTO sites (id, organization_id, site_code, site_name, address_text, city, country_code, is_central_function) VALUES
('31000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001','SITE-HQ','Demo Head Office','Fictional HQ','Demo City','VN',true),
('31000000-0000-0000-0000-000000000002','30000000-0000-0000-0000-000000000001','SITE-02','Demo Operations Site','Fictional operations site','Demo City','VN',false);

INSERT INTO contacts (id, organization_id, site_id, full_name, email, job_title) VALUES
('32000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001','31000000-0000-0000-0000-000000000001','Demo Customer Contact','customer@example.invalid','Management Representative');

INSERT INTO auditors (id, auditor_code, display_name, email) VALUES
('40000000-0000-0000-0000-000000000001','AUD-DEMO-01','Demo Lead Auditor','auditor@example.invalid');

INSERT INTO audit_projects (id, project_code, organization_id) VALUES
('50000000-0000-0000-0000-000000000001','DEMO-PROJECT-001','30000000-0000-0000-0000-000000000001');

INSERT INTO audits (id, audit_no, project_id, audit_type, status, start_date, end_date, planned_days, lead_auditor_id, scope_text) VALUES
('60000000-0000-0000-0000-000000000001','DEMO-AUDIT-001','50000000-0000-0000-0000-000000000001','SURVEILLANCE','IN_PROGRESS','2026-08-10','2026-08-11',2.00,'40000000-0000-0000-0000-000000000001','Demo scope for architecture testing only');

INSERT INTO audit_sites (audit_id, site_id, planned_days, is_primary_site) VALUES
('60000000-0000-0000-0000-000000000001','31000000-0000-0000-0000-000000000001',1.50,true),
('60000000-0000-0000-0000-000000000001','31000000-0000-0000-0000-000000000002',0.50,false);

INSERT INTO audit_schemes (audit_id, scheme_id, scope_text) VALUES
('60000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','Demo ISMS scope');

INSERT INTO audit_assignments (audit_id, auditor_id, site_id, scheme_id, role, audit_days, is_team_lead) VALUES
('60000000-0000-0000-0000-000000000001','40000000-0000-0000-0000-000000000001','31000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','LEAD_AUDITOR',1.50,true);

INSERT INTO focus_areas (id, audit_id, name, description, sort_order) VALUES
('70000000-0000-0000-0000-000000000001','60000000-0000-0000-0000-000000000001','Risk Treatment','Demo focus area for structured audit testing',1);

INSERT INTO findings (id, audit_id, site_id, scheme_id, focus_area_id, finding_no, category, title, statement_text, objective_evidence, requirement_reference, status, created_by) VALUES
('80000000-0000-0000-0000-000000000001','60000000-0000-0000-0000-000000000001','31000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','70000000-0000-0000-0000-000000000001','DEMO-NC-001','MINOR_NC','Demo control record gap','A fictional demonstration finding for workflow testing.','Demo evidence reference only.','Example clause reference','OPEN','40000000-0000-0000-0000-000000000001');

INSERT INTO finding_status_history (finding_id, from_status, to_status, changed_by, comment) VALUES
('80000000-0000-0000-0000-000000000001','DRAFT','OPEN','40000000-0000-0000-0000-000000000001','Demo lifecycle transition');

INSERT INTO statements (audit_id, topic_code, topic_title, assessment_state, final_text, customer_visible, sort_order, created_by) VALUES
('60000000-0000-0000-0000-000000000001','INTERNAL_AUDIT','Internal audit','ASSESSED','Demo statement: internal audit process was sampled. No real customer data is represented.',true,1,'40000000-0000-0000-0000-000000000001');
