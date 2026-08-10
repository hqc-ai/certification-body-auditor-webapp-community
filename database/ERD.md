# Entity Relationship Diagram — Community Phase 1A / 1B / 1C

**Primary author / architecture lead**  
Nguyễn Đăng Quang  
Lead Auditor ISO/IEC 27001, ISO/IEC 42001, ISO/IEC 27701  
Project Lead – AI Governance and AIMS Platform Development

This document shows the Community relational model at two levels:

1. a readable high-level domain ERD;
2. Phase 1C operational extensions.

The SQL extension is in [`phase-1c-extension.sql`](phase-1c-extension.sql).

## 1. High-Level Community ERD

```mermaid
erDiagram
    ORGANIZATIONS ||--o{ SITES : has
    ORGANIZATIONS ||--o{ CONTACTS : has
    ORGANIZATIONS ||--o{ AUDIT_PROJECTS : owns
    ORGANIZATIONS ||--o{ CERTIFICATIONS : holds

    STANDARDS ||--o{ SCHEMES : defines
    SCHEMES ||--o{ CERTIFICATIONS : applies

    AUDIT_PROJECTS ||--o{ AUDITS : contains
    AUDITS ||--o{ AUDIT_SITES : covers
    SITES ||--o{ AUDIT_SITES : participates
    AUDITS ||--o{ AUDIT_SCHEMES : assesses
    SCHEMES ||--o{ AUDIT_SCHEMES : participates

    AUDITS ||--o{ AUDIT_ASSIGNMENTS : has
    AUDITORS ||--o{ AUDIT_ASSIGNMENTS : receives
    AUDITORS ||--o{ COMPETENCIES : has

    AUDITS ||--o{ FOCUS_AREAS : contains
    AUDITS ||--o{ FINDINGS : raises
    FOCUS_AREAS ||--o{ FINDINGS : groups
    FINDINGS ||--o{ EVIDENCE : supported_by
    AUDITS ||--o{ EVIDENCE : collects

    AUDITS ||--o{ MANAGEMENT_SUMMARIES : summarizes
    AUDITS ||--o| CONCLUSIONS : concludes
    AUDITS ||--o{ STATEMENTS : records
    AUDITS ||--o{ AUDIT_DOCUMENTS : owns
    AUDITS ||--o{ AUDIT_REPORTS : generates

    AUDITS ||--o{ TECHNICAL_REVIEWS : undergoes
    AUDITS ||--o{ AUDIT_STATUS_HISTORY : traces
    FINDINGS ||--o{ FINDING_STATUS_HISTORY : traces
```

## 2. Phase 1C Identity & Operations ERD

```mermaid
erDiagram
    USERS ||--o{ USER_ROLES : has
    ROLES ||--o{ USER_ROLES : grants

    USERS ||--o{ AUDIT_ROLE_ASSIGNMENTS : receives
    AUDITS ||--o{ AUDIT_ROLE_ASSIGNMENTS : scopes

    CONTACTS ||--o{ CUSTOMER_PORTAL_ACCESS : authorizes
    USERS ||--o{ CUSTOMER_PORTAL_ACCESS : may_use
    ORGANIZATIONS ||--o{ CUSTOMER_PORTAL_ACCESS : scopes
    AUDITS ||--o{ CUSTOMER_PORTAL_ACCESS : optionally_scopes

    AUDITS ||--o{ TECHNICAL_REVIEWS : undergoes
    USERS ||--o{ TECHNICAL_REVIEWS : reviews
    TECHNICAL_REVIEWS ||--o{ TECHNICAL_REVIEW_ACTIONS : records

    REVIEW_CHECKLIST_ITEMS ||--o{ REVIEW_CHECKLIST_RESPONSES : asks
    TECHNICAL_REVIEWS ||--o{ REVIEW_CHECKLIST_RESPONSES : answers

    AUDITS ||--o{ CERTIFICATION_DECISIONS : receives
    TECHNICAL_REVIEWS ||--o{ CERTIFICATION_DECISIONS : supports
    USERS ||--o{ CERTIFICATION_DECISIONS : decides
```

## 3. Customer Corrective Action & Publication ERD

```mermaid
erDiagram
    FINDINGS ||--o{ FINDING_CUSTOMER_RESPONSES : receives
    USERS ||--o{ FINDING_CUSTOMER_RESPONSES : submits

    FINDING_CUSTOMER_RESPONSES ||--o{ RESPONSE_EVIDENCE : supports
    AUDIT_DOCUMENTS ||--o{ RESPONSE_EVIDENCE : stores

    AUDIT_DOCUMENTS ||--o{ DOCUMENT_PUBLICATIONS : publishes
    AUDITS ||--o{ DOCUMENT_PUBLICATIONS : scopes
    USERS ||--o{ DOCUMENT_PUBLICATIONS : acts

    USERS ||--o{ NOTIFICATIONS : receives
    AUDITS ||--o{ REMINDERS : has
    FINDINGS ||--o{ REMINDERS : has
```

## 4. Important Cardinality Notes

- One organization may have many projects/audits and many customer contacts.
- Audit-to-site and audit-to-scheme are many-to-many through association tables.
- Auditor assignment data is separate from the auditor master.
- Global user roles are separate from audit-specific role assignments.
- An audit may have multiple Technical Review cycles over time.
- A Certification Decision references the Technical Review used as its prerequisite.
- A finding may have many customer response versions.
- A response may have multiple evidence documents.
- A document may have many publication events or audience records.
- Customer portal access does not imply that all audit documents are visible.

## 5. Object Storage Boundary

Binary files should remain outside PostgreSQL in S3-compatible object storage.

Relational records retain:

- storage key;
- MIME type;
- checksum/hash;
- ownership;
- audit/finding/response relationship;
- publication state;
- actor and timestamps.

## 6. Authorization Boundary

The ERD intentionally models both:

- **who may access an audit** (`customer_portal_access`, role assignments); and
- **what may be exposed** (`document_publications`, domain visibility rules).

These are separate controls.
