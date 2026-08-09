# Entity Relationship Diagram

**Primary author / architecture lead**  
Nguyễn Đăng Quang  
Lead Auditor ISO/IEC 27001, ISO/IEC 42001, ISO/IEC 27701  
Project Lead – AI Governance and AIMS Platform Development  
NQA Viet Nam

This ERD corresponds to [schema.sql](schema.sql).

```mermaid
erDiagram
    ORGANIZATIONS ||--o{ SITES : owns
    ORGANIZATIONS ||--o{ CONTACTS : has
    ORGANIZATIONS ||--o{ AUDIT_PROJECTS : has
    STANDARDS ||--o{ SCHEMES : supports
    ORGANIZATIONS ||--o{ CERTIFICATIONS : holds
    SCHEMES ||--o{ CERTIFICATIONS : contextualizes
    AUDITORS ||--o{ COMPETENCIES : has
    AUDIT_PROJECTS ||--o{ AUDITS : contains
    AUDITS ||--o{ AUDIT_SITES : covers
    SITES ||--o{ AUDIT_SITES : participates
    AUDITS ||--o{ AUDIT_SCHEMES : covers
    SCHEMES ||--o{ AUDIT_SCHEMES : participates
    CERTIFICATIONS ||--o{ AUDIT_SCHEMES : relates
    AUDITS ||--o{ AUDIT_ASSIGNMENTS : assigns
    AUDITORS ||--o{ AUDIT_ASSIGNMENTS : receives
    SITES ||--o{ AUDIT_ASSIGNMENTS : allocated
    SCHEMES ||--o{ AUDIT_ASSIGNMENTS : allocated
    AUDITS ||--o{ FOCUS_AREAS : contains
    AUDITS ||--o{ FINDINGS : contains
    FOCUS_AREAS ||--o{ FINDINGS : groups
    FINDINGS ||--o{ FINDING_RESPONSES : receives
    FINDINGS ||--o{ FINDING_STATUS_HISTORY : transitions
    AUDITS ||--o{ EVIDENCE : contains
    FINDINGS ||--o{ EVIDENCE : supports
    FOCUS_AREAS ||--o{ EVIDENCE : supports
    AUDITS ||--o{ MANAGEMENT_SUMMARIES : summarizes
    FOCUS_AREAS ||--o{ MANAGEMENT_SUMMARIES : contextualizes
    AUDITS ||--o| CONCLUSIONS : concludes
    AUDITS ||--o{ STATEMENTS : assesses
    AUDITS ||--o{ AUDIT_DOCUMENTS : has
    FINDINGS ||--o{ AUDIT_DOCUMENTS : attaches
    AUDITS ||--o{ AUDIT_REPORTS : renders
    AUDIT_DOCUMENTS ||--o{ AUDIT_REPORTS : stores
    AUDITS ||--o{ TECHNICAL_REVIEWS : undergoes
    AUDITS ||--o{ AUDIT_STATUS_HISTORY : transitions
```

## Cardinality Notes

- Audit-to-site and audit-to-scheme are many-to-many through join entities.
- Audit-to-auditor is many-to-many through `audit_assignments`; one person can hold multiple audit-context assignments.
- A finding can have many response versions and many lifecycle history records.
- `conclusions` is one-per-audit in the Phase 1 schema; statements and summaries are one-to-many.
- Evidence may link to an audit generally or optionally to a finding/focus area.
- Technical review is separate from audit state and may support multiple review iterations.

## Object Storage Boundary

Binary evidence and generated report files are stored outside PostgreSQL. `evidence.storage_key` and `audit_documents.storage_key` are references into the chosen S3-compatible object storage implementation.
