# Phase 1B – Audit Workspace Architecture

Phase 1B defines the detailed workspace opened for a scheduled audit. The primary objective is to let the auditor enter structured audit data while exposing only approved customer-facing outputs.

**Primary author / architecture lead**  
Nguyễn Đăng Quang  
Lead Auditor ISO/IEC 27001, ISO/IEC 42001, ISO/IEC 27701  
Project Lead – AI Governance and AIMS Platform Development  
NQA Viet Nam

## Architectural Rules

1. Structured audit data is the source of truth; generated reports are projections/snapshots.
2. Audit execution, finding follow-up, technical review, certification workflow, and report publication are separate lifecycles.
3. Single-site/single-scheme use should be simple, but the model must not block integrated or multi-site audits.
4. AI output is draft/advisory until a human auditor reviews and accepts it.
5. Customer-visible output must use explicit publication/visibility rules.

## Workspace Map

```text
Audit Workspace
├── Current / Historical Overview
├── Focus Areas
├── Findings & Follow-up
├── Evidence
├── Management Summary
├── Conclusions
├── Statements
├── Customer Output / Presentation
├── Technical Summary (read model)
├── Audit Completion / Readiness
└── Technical Review (staged downstream workflow)
```

## Current / Historical Audit Overview

**Purpose:** aggregate current audit context and preserve access to relevant history.

**Actors:** Auditor, Lead Auditor, Technical Reviewer (read-only downstream).

**Inputs:** organization, sites, contacts, team, audit dates/days, schemes, scope, current findings, previous audit references.

**Outputs:** current overview DTO and historical comparison views.

**Business rules:** historical records are queried, not copied over current records; overall-audit and site-specific contexts are distinct.

**Entities:** `organizations`, `sites`, `contacts`, `audits`, `audit_sites`, `audit_schemes`, `audit_assignments`, `findings`.

**API:** `GET /audits/{id}` and dedicated historical/read-model endpoints.

**Future extensions:** performance trend summaries and prior-cycle comparison.

## Focus Areas

**Purpose:** organize audit themes, findings, evidence, and management-summary content.

**Actors:** Auditor.

**Inputs:** reusable library/template item or audit-specific title/description.

**Outputs:** focus-area records and ordered audit views.

**Business rules:** a finding may reference a focus area; focus-area rating/control level is optional and scheme/template-dependent.

**Entities:** `focus_areas`, `findings`, `management_summaries`, `evidence`.

**Workflow:** create/select -> assess -> link evidence/findings -> summarize.

**API:** `GET/POST /audits/{id}/focus-areas`.

**Future extensions:** reusable focus-area libraries and cross-audit trend analysis.

## Findings & Follow-up

**Purpose:** capture structured audit findings and preserve their post-audit response lifecycle.

**Actors:** Auditor, Lead Auditor, Customer/Auditee Viewer for published findings.

**Inputs:** title, statement, objective evidence, requirement reference, category, scheme, site, focus area, attachments/evidence.

**Outputs:** finding record, publication state, response history, review result, closure status.

**Business rules:**
- finding number is stable after creation;
- customer response is a separate append-only/versioned record;
- status transition is validated and historized;
- finding may remain open after the audit execution is completed;
- closing is an action with validation, not arbitrary status editing.

**Entities:** `findings`, `finding_responses`, `finding_status_history`, `evidence`.

**Workflow:** see [Finding Lifecycle](../domain/finding-lifecycle.md).

**API considerations:** use explicit action endpoints for share, response, review, close, and reopen.

**Future extensions:** configurable scheme-specific categories/due dates and collaborative customer response.

## Evidence Management

**Purpose:** preserve traceable source material and attachment metadata without storing large binaries in PostgreSQL.

**Actors:** Auditor; Customer only for specifically published/uploaded items.

**Inputs:** file/object reference, description, evidence type, source context, visibility, related audit/finding/focus area.

**Outputs:** evidence metadata and controlled object-storage reference.

**Business rules:** object storage holds binary files; database stores metadata, hashes where useful, and visibility. Evidence used in controlled decisions should not be silently overwritten.

**Entities:** `evidence`, `audit_documents`.

**API considerations:** upload endpoints should issue controlled storage keys and never trust client-supplied visibility alone.

**Future extensions:** malware scanning, content hashing, retention rules, evidence citations into reports, AI provenance links.

## Management Summary

**Purpose:** summarize positive indications, main areas for improvement, and other audit-level narrative.

**Actors:** Lead Auditor, Auditor.

**Inputs:** focus areas, findings, evidence, optional control/rating value.

**Outputs:** overall and/or focus-area summaries.

**Business rules:** rating is nullable/extensible; final customer-facing narrative is selected/published, not automatically inferred from drafts.

**Entities:** `management_summaries`, `focus_areas`, `findings`.

**API:** `GET/PUT /audits/{id}/management-summaries`.

**Future extensions:** bilingual fields, AI-assisted draft summary with provenance.

## Conclusions

**Purpose:** record controlled audit-level conclusions and recommendations without overwriting downstream approved certification data.

**Actors:** Lead Auditor.

**Inputs:** completion context, audit objectives, scope, findings, required conclusion topics.

**Outputs:** conclusion narrative and controlled recommendation fields.

**Business rules:** mandatory topics are validation rules; audit recommendation is distinct from certification decision; proposed changes do not directly overwrite approved certification master data.

**Entities:** `conclusions`, `audits`, optionally `certifications`.

**API:** `GET/PUT /audits/{id}/conclusions`.

**Future extensions:** scheme-specific conclusion templates and formal certification recommendation objects.

## Auditor Statements

**Purpose:** capture reusable assessment topics with audit-specific final text.

**Actors:** Auditor, Lead Auditor.

**Inputs:** stable topic code, selected/default statement, edited narrative, optional rating/state.

**Outputs:** audit-specific statement results used by reports and future comparisons.

**Business rules:** stable topic identifiers are required for longitudinal comparison; `NOT_APPLICABLE`, `NOT_ASSESSED`, and an actual rating are different states.

**Entities:** `statements`.

**API:** `GET/PUT /audits/{id}/statements`.

**Future extensions:** reusable statement library, multilingual statements, AI draft from notes.

## Customer-visible Output and Reporting

**Purpose:** render only approved/selected audit content for the customer.

**Actors:** Lead Auditor; Customer/Auditee Viewer.

**Inputs:** final findings, management summary, conclusions, statements, report metadata.

**Outputs:** web customer view and versioned report snapshot/export metadata.

**Business rules:** generated outputs are not the editing source of truth; publication scope is explicit; output snapshot records template version and source revision/hash where practical.

**Entities:** `audit_reports`, `audit_documents`, plus source content entities.

**API:** `POST /audits/{id}/reports`, `GET /audits/{id}/customer-view`.

**Future extensions:** PDF/DOCX renderer, closing presentation, bilingual output.

## Audit Completion / Readiness

**Purpose:** make completion a validated business transition.

**Actors:** Lead Auditor in future role-aware operation; single user in Community MVP.

**Inputs:** required audit metadata, findings, summaries, conclusions, statements, site completion, evidence/document requirements.

**Outputs:** readiness checks and completion transition.

**Business rules:** data validation and permission validation are separate; site-level completeness can gate overall completion; open finding follow-up does not necessarily mean audit execution is incomplete.

**API:** `GET /audits/{id}/readiness`, `POST /audits/{id}/complete`.

## Technical Review

**Purpose:** represent independent downstream assurance over a completed audit package.

**Actors:** Technical Reviewer, certification personnel.

**Inputs:** completed audit package, recommendation, report, internal technical data.

**Outputs:** review state, result, comments, and timestamps.

**Business rules:** technical review has its own object and lifecycle; reviewer notes are internal by default; reviewer role is distinct from audit-execution roles.

**Entities:** `technical_reviews`, `audit_documents`, `audit_reports`.

**API:** `POST /audits/{id}/technical-reviews`, staged for later implementation.

## Certification Workflow Boundary

Certification data and decisions are downstream governance concerns. The audit workspace may reference certification context and record recommendations/proposed changes, but must not present an auditor recommendation as a certification decision.

Potential community entities include `certifications` and `audit_schemes`; a fuller certification-decision model is intentionally deferred.

## Future AI Services

Future AI support may:
- draft a finding from auditor notes and selected scheme/context;
- draft a statement or management summary;
- warn about internal inconsistencies or missing evidence.

Controls:
- AI suggestions remain explicitly draft/advisory;
- auditor notes/source evidence remain traceable;
- human review is mandatory before controlled content is saved/published;
- AI does not autonomously close findings, change certification scope, or make certification decisions.

## Related Documents

- [Phase 1A Application Architecture](phase-1a-application-architecture.md)
- [Database & Data Model](database-data-model-architecture.md)
- [Report Model](../domain/report-model.md)
