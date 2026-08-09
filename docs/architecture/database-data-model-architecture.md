# Database & Data Model Architecture

## Baseline

**Primary database:** PostgreSQL  
**File/object storage:** S3-compatible object storage (implementation choice)  
**Application mode:** online-first web application  
**Model style:** normalized relational core with selective JSONB only for non-core extension metadata

**Primary author / architecture lead**  
Nguyễn Đăng Quang  
Lead Auditor ISO/IEC 27001, ISO/IEC 42001, ISO/IEC 27701  
Project Lead – AI Governance and AIMS Platform Development  
NQA Viet Nam

## Goals

- decouple database design from individual screens;
- support multiple sites, schemes, and assignments per audit;
- preserve traceability and historical state;
- support structured reporting and customer publication;
- keep Phase 1 simple while leaving extension points for authentication, technical review, customer portal, competence management, and AI assistance.

## Bounded Domains

| Domain | Responsibility | Main community entities |
|---|---|---|
| Organization Master | organization, sites, contacts | `organizations`, `sites`, `contacts` |
| Certification Context | standards/schemes and existing certification reference | `standards`, `schemes`, `certifications` |
| Auditor & Competence | auditor identity and reusable competence/qualification | `auditors`, `competencies` |
| Audit Core | lifecycle, sites, schemes, assignments | `audit_projects`, `audits`, `audit_sites`, `audit_schemes`, `audit_assignments`, `audit_status_history` |
| Audit Content | focus areas, findings, responses, summaries, conclusions, statements | `focus_areas`, `findings`, `finding_responses`, `finding_status_history`, `management_summaries`, `conclusions`, `statements` |
| Evidence & Documents | traceable evidence and generated/document metadata | `evidence`, `audit_documents` |
| Reporting | versioned generated audit output metadata | `audit_reports` |
| Review | downstream independent technical review | `technical_reviews` |

## Core Relationship Model

```text
organizations 1---* sites
organizations 1---* contacts
organizations 1---* audit_projects 1---* audits

audits *---* sites      via audit_sites
audits *---* schemes    via audit_schemes
audits 1---* audit_assignments *---1 auditors

audits 1---* focus_areas
audits 1---* findings
findings 1---* finding_responses
findings 1---* finding_status_history
findings 1---* evidence

audits 1---* management_summaries
audits 1---0..1 conclusions
audits 1---* statements
audits 1---* audit_documents
audits 1---* audit_reports
audits 1---* technical_reviews
audits 1---* audit_status_history
```

## Key Business Rules

1. One audit may cover multiple schemes and sites; never force a single site/scheme relationship into `audits`.
2. Auditor role, allocation, site, scheme, dates, days, and hours belong to `audit_assignments`.
3. Finding numbers are stable business identifiers after creation.
4. Customer responses are separate versioned records and must not overwrite previous responses.
5. Material lifecycle transitions are recorded in history tables in the same transaction as current-state updates.
6. Customer-visible data is explicitly published/selected; internal reviewer and competence data is not exposed by default.
7. Large binaries live in object storage; relational tables hold metadata and storage references.
8. Reports are generated from live structured data and recorded as snapshots/outputs, not edited as the primary data source.
9. Certificate/business dates use SQL `date`; event timestamps use `timestamptz`.
10. Physical deletion of controlled audit records should be restricted after material workflow states are reached.

## Identifier and Timestamp Strategy

Use UUID primary keys for domain entities and separate human-readable codes where needed. PostgreSQL `gen_random_uuid()` is suitable for a reference implementation. Use `created_at` and `updated_at` consistently for mutable entities. Use dedicated timestamps for business events such as submission, publication, review, close, and generation.

## Referential Integrity

- Prefer `ON DELETE RESTRICT` for historical/controlled relationships.
- Use `ON DELETE CASCADE` only for safe child records whose lifecycle cannot outlive a draft parent.
- Use composite uniqueness for join tables, e.g. `(audit_id, site_id)`.
- Never store comma-separated UUID collections in text.
- Use check constraints for stable community baseline status/category values; replace with configurable lookup tables when operational terminology becomes organization-specific.

## Visibility and Data Protection

Every evidence/document/report that can cross the internal/customer boundary carries explicit visibility or publication state. Customer endpoints use allowlisted DTOs. The database model is prepared for future actor IDs and authentication even though Phase 1 may run as a single-user demonstration.

## Report Data Architecture

```text
PostgreSQL structured audit data
        |
        +--> Report DTO / Projection
        |      organization / site / schemes
        |      team / dates / scope
        |      focus areas / findings / evidence refs
        |      management summary
        |      conclusions / statements
        |
        +--> Customer Web View
        |
        +--> Report Renderer (future PDF/DOCX)
        |
        `--> audit_reports + audit_documents metadata
```

`audit_reports` should record output type, template version, generated time, publication state, object-storage key, and optionally a source revision/hash.

## AI Data Boundary

The accepted professional record remains in the normal audit tables. Do not create a special “AI finding” business type. If provenance is later required, add a separate `ai_generation_events` extension table/service containing model/prompt/context/output/acceptance metadata. This table is intentionally not part of the Phase 1 core schema.

## Implementation Guidance

- UUID domain primary keys
- `numeric(6,2)` for audit days/hours rather than floating point
- `date` for audit/certification business dates
- `timestamptz` for events
- indexed foreign keys and common list filters
- centrally validated state transitions
- optimistic locking/version field can be added for multi-user high-conflict records
- avoid a duplicate `technical_summary` mega-table; build technical summaries as read models over normalized entities

## Initial Read Models

- Audit List summary
- Audit Workspace overview
- Historical findings for organization/scheme context
- Focus-area summary
- Finding follow-up queue
- Customer-visible audit output
- Technical Summary projection
- Technical Review package

## Phase 1 Exclusions

- offline synchronization/conflict tables
- enterprise identity schema beyond future-ready actor references
- complex accreditation/certificate authorization engine
- analytics warehouse
- AI prompt/provenance store
- speculative microservices/event-bus infrastructure

## SQL Implementation

See [database/schema.sql](../../database/schema.sql) and [database/ERD.md](../../database/ERD.md).
