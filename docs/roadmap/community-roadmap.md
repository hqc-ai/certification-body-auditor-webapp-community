# Community Roadmap

**Primary author / architecture lead**  
Nguyễn Đăng Quang  
Lead Auditor ISO/IEC 27001, ISO/IEC 42001, ISO/IEC 27701  
Project Lead – AI Governance and AIMS Platform Development  
NQA Viet Nam

This roadmap is a proposal for staged community development. Later phases are not commitments or claims of existing implementation.

## Phase 1 – Core Auditor Workspace

Goal: demonstrate the full structured audit workflow and relational model with a simple web-first implementation.

Candidate deliverables:
- Audit List and audit shell
- organization/site/scheme/assignment data
- focus areas
- findings and evidence
- finding response/follow-up lifecycle
- management summary
- conclusions and statements
- customer-safe web output
- report snapshot model
- readiness/completion validation
- PostgreSQL schema and demo seed data

## Phase 2 – Authentication and Multi-user Operation

Candidate deliverables:
- user accounts / identity-provider integration
- role and permission model
- auditor/customer/reviewer access control
- optimistic locking/versioning for collaborative edits
- activity/audit logging improvements
- secure object-storage upload/download flows

## Phase 3 – Customer Portal

Candidate deliverables:
- customer identity and organization membership
- published findings and response submission
- evidence upload for corrective-action response
- released audit outputs
- notification hooks
- strict customer-safe DTO/API boundary

## Phase 4 – Technical Review and Certification Workflow

Candidate deliverables:
- technical-review queue and independent review records
- review findings/reversion logic where required
- certification recommendation package
- proposed vs approved scope/change governance
- integration extension points to an external certification management system

Certification decisions remain controlled professional/governance processes and are not inferred automatically from audit completion.

## Phase 5 – AI-assisted Auditing

Candidate deliverables:
- finding draft assistance from auditor notes/evidence
- statement and summary drafting
- consistency and missing-evidence checks
- explicit AI provenance records
- human approval gates
- model/prompt version traceability

AI supports auditors; it does not replace professional judgement or make autonomous certification decisions.

## Phase 6 – Analytics, Audit Intelligence, and Organizational Knowledge

Candidate deliverables:
- cross-audit finding trends
- focus-area and statement history
- organization/site risk and performance views
- audit knowledge reuse
- reusable evidence/reference patterns
- governed retrieval/knowledge assistance

Analytics should remain downstream from stable operational workflows and should not distort the source audit data model.
