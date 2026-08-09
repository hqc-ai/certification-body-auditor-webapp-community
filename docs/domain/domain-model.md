# Domain Model

**Primary author / architecture lead**  
Nguyễn Đăng Quang  
Lead Auditor ISO/IEC 27001, ISO/IEC 42001, ISO/IEC 27701  
Project Lead – AI Governance and AIMS Platform Development  
NQA Viet Nam

## Domain Vocabulary

The Community Edition uses generic conformity-assessment terminology. Organization master data is separated from audit-specific associations so that the same organization, site, scheme, auditor, and certification context can be reused across audits without duplicating the underlying records.

| Entity | Responsibility |
|---|---|
| Organization | Audited/legal or operating entity master |
| Site | Physical or operational location belonging to an organization |
| Contact | Organization or site contact; future portal identity is separate |
| Standard | Versioned standard reference, e.g. ISO/IEC 27001:2022 |
| Scheme | Assessment/certification service context linked to a standard where relevant |
| Certification | Optional existing certification context used by audit/report/recommendation workflows |
| Audit Project | Container for related audits over an organization/certification context |
| Audit | Core scheduled/executed assessment event |
| Audit Site | Audit-to-site relationship with audit-specific scope/allocation |
| Audit Scheme | Audit-to-scheme relationship with audit-specific scope/context |
| Auditor | Professional participant master record |
| Competency | Reusable qualification/competence record for an auditor |
| Audit Assignment | Auditor allocation to audit/site/scheme/role/time context |
| Focus Area | Audit theme used to group work, findings, and summary content |
| Finding | Structured nonconformity/observation/improvement or other configured finding |
| Finding Response | Versioned customer/auditee response record |
| Evidence | Traceable evidence metadata tied to audit/finding/focus area |
| Management Summary | Overall or focus-area summary narrative |
| Conclusion | Controlled audit-level conclusion/recommendation narrative |
| Statement | Stable assessment topic with audit-specific final text/state/rating |
| Audit Document | File metadata and visibility/publication information |
| Audit Report | Generated customer-facing output snapshot metadata |
| Technical Review | Independent downstream review of completed audit package |
| Status History | Append-only lifecycle transition record |

## Aggregate and Boundary Guidance

`Audit` is the operational aggregate root for the workspace, but it is not a universal owner of every lifecycle. Findings, technical reviews, and certification decisions have their own state and validation logic.

Do not collapse the following statuses:
- audit status;
- finding status;
- technical-review status;
- certification status;
- competency status.

## Multi-Site / Multi-Scheme Rule

The model must support:

```text
Audit A
  Sites: Site 1, Site 2, Site 3
  Schemes: Scheme X, Scheme Y
  Assignments:
    Auditor 1 -> Lead -> Site 1 -> Scheme X
    Auditor 1 -> Auditor -> Site 2 -> Scheme Y
    Auditor 2 -> Auditor -> Site 3 -> Scheme X
```

This is why `audit_sites`, `audit_schemes`, and `audit_assignments` are relationship entities.

## Internal vs Customer Boundary

Customer-facing views can include explicitly published findings, customer response forms, selected management summaries, conclusions/statements, and released audit reports. They exclude internal reviewer comments, audit logs, competence information, and certification-governance details unless a separate business rule explicitly publishes them.

## Extension Points

Future subsystems may add:
- authentication/users and role assignments;
- customer portal identity;
- detailed competence evaluation per assignment;
- certification programme/site sampling;
- accreditation and technical classification reference data;
- certification decision/authorization;
- AI provenance events;
- analytics/read warehouse.

These extensions should reference the stable core IDs rather than replace the core domain.
