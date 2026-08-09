# Report Model

**Primary author / architecture lead**  
Nguyễn Đăng Quang  
Lead Auditor ISO/IEC 27001, ISO/IEC 42001, ISO/IEC 27701  
Project Lead – AI Governance and AIMS Platform Development  
NQA Viet Nam

## Principle: Structured Data -> Projection -> Output

The audit report is not the primary editable data store. Professional content is authored in structured domain modules and projected into customer-facing views and generated files.

```text
Audit Domain Data
   |
   +-- Overview projection
   +-- Findings projection
   +-- Management Summary projection
   +-- Conclusions projection
   +-- Statements projection
   |
   v
Report DTO / View Model
   |
   +-- Customer Web View
   +-- Audit Report Renderer
   +-- Closing Presentation Renderer (future)
   +-- Other scheme-specific renderer (future)
   |
   v
AuditReport + AuditDocument output metadata
```

## Report Inputs

Typical report inputs include:
- organization and site details;
- audit dates, type, scope, schemes, and team;
- selected focus areas;
- published/final findings;
- approved management summary;
- conclusions;
- selected statements;
- selected evidence references where appropriate;
- report template/version metadata.

## Output Snapshot

`audit_reports` should record:
- audit ID;
- report type;
- report status (`DRAFT`, `FINAL`, `RELEASED`, etc.);
- template name/version;
- generated timestamp and actor;
- publication/release timestamp;
- object-storage key or linked document ID;
- optional source data revision/hash.

Generated files can be stored in object storage and linked via `audit_documents`.

## Customer Visibility

A report renderer receives an explicit customer-safe projection. It must not serialize the entire audit aggregate. Internal reviewer notes, competence records, private evidence, logs, or technical governance data are omitted unless a specific publication rule allows them.

## Dynamic Content

Report/presentation pagination and section count should be data-driven. For example, a report can render one detailed block per finding without relying on fixed page counts.

## Future Multilingual Support

If bilingual reporting is required, store language-specific professional text at the structured-data level or in versioned translations; do not rely solely on translating a finished PDF/DOCX during export.

## Future AI Assistance

AI may draft summaries or perform consistency checks, but the final report projection must only use auditor-approved content. AI-generated text must not be automatically published.
