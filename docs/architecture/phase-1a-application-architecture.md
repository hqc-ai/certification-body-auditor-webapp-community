# Phase 1A – Application Architecture

## Status and Intent

Phase 1A defines the minimal web application shell for the Community MVP. Its purpose is to provide an Audit List, minimal audit metadata, navigation into an Audit Workspace, and stable extension points for the detailed audit workflow. Authentication is not required for the first single-user demonstration.

**Primary author / architecture lead**  
Nguyễn Đăng Quang  
Lead Auditor ISO/IEC 27001, ISO/IEC 42001, ISO/IEC 27701  
Project Lead – AI Governance and AIMS Platform Development  
NQA Viet Nam

## Design Boundary

Phase 1A is deliberately smaller than a full certification-management platform. It keeps only the architecture required to support the later audit-detail workflow.

### In scope

- Audit List as the primary work queue
- Create, edit, open, and view an audit
- Organization, site, scheme, dates, audit type/stage, status, and assignment context
- Multiple sites and multiple schemes in the domain model
- Separate assignment relationship for auditor role, dates, days/hours, site, and scheme
- Route and component shell for detailed audit modules
- Explicit customer-visible-output boundary

### Deferred

- Authentication and MFA
- Offline mode, synchronization, and conflict handling
- Full calendar and weekly capacity management
- Auditor analytics dashboard
- Full competence-management workflow
- Production technical-review queue
- Certificate authorization/decision workflow
- Full customer portal identity and access management

## Major Module: Audit List

**Purpose:** provide a stable entry point into active and historical audit work.

**Primary actors:** Auditor, Lead Auditor.

**Inputs:** audit records, dates, organization, schemes, status, assigned role.

**Outputs:** filtered work queue and navigation to the audit workspace.

**Business rules:**
- one audit may reference multiple sites, schemes, and assignments;
- list status is derived from the audit lifecycle only, not finding or review status;
- customer visibility is not inferred from presence in the list.

**Main data entities:** `audits`, `audit_projects`, `organizations`, `audit_sites`, `audit_schemes`, `audit_assignments`.

**Workflow:** list -> filter/select -> open audit -> route to audit overview.

**API considerations:** use a summary/read DTO rather than serializing full relational entities. Filtering by date, status, organization, scheme, and assigned auditor can be added without changing the core model.

**Future extensions:** calendar view, workload planning, assignment acceptance, role-based work queues.

## Major Module: Minimal Audit Editor

**Purpose:** create the operational audit aggregate before detailed execution begins.

**Primary actors:** Auditor or project coordinator in the Community MVP.

**Inputs:** organization, project, audit type, start/end dates, site(s), scheme(s), assignment(s).

**Outputs:** auditable structured audit record ready for Phase 1B execution.

**Business rules:**
- do not store one `site_id` or one `scheme_id` directly on the audit as the only relationship;
- assignments are relationship objects, not properties of an auditor profile;
- business dates use date semantics where time-of-day is irrelevant;
- status transitions should eventually be centralized in an application/domain service.

**Main data entities:** `audits`, `audit_sites`, `audit_schemes`, `audit_assignments`, `audit_status_history`.

**API considerations:** prefer explicit nested commands/actions or resource endpoints for adding/removing site, scheme, and assignment links.

## Navigation

```text
/
└── /audits
    ├── /new
    └── /:auditId
        ├── /overview
        ├── /focus-areas
        ├── /findings
        ├── /management-summary
        ├── /conclusions
        ├── /statements
        ├── /evidence
        ├── /report
        ├── /customer-view
        └── /technical-review   # staged/internal
```

Authentication can later be inserted above these routes without replacing the audit route hierarchy.

## Visibility Classes

| Class | Meaning | Examples |
|---|---|---|
| Auditor Input | Professional working content | findings, evidence notes, summaries |
| System / Master Data | reusable or scheduled context | organization, sites, schemes, dates |
| Customer Visible/Input | explicitly published or submitted | shared findings, responses, released report |
| Internal Only | certification-body governance | reviewer notes, competency checks, internal logs |

Visibility must be enforced server-side by policy/DTO selection. Hiding a component in the browser is not access control.

## Phase 1A API Boundary

Suggested resource surface (not a frozen contract):

```text
GET    /audits
POST   /audits
GET    /audits/{id}
PATCH  /audits/{id}
POST   /audits/{id}/sites
POST   /audits/{id}/schemes
POST   /audits/{id}/assignments
GET    /audits/{id}/workspace-summary
```

## Extension Points

- Identity provider and role/permission service
- Planning/calendar service
- Competency/qualification subsystem
- Technical-review task engine
- Certification workflow integration
- Reporting template registry
- AI-assist service

## Acceptance Criteria

- An audit can contain multiple sites and multiple schemes without duplicating the audit row.
- One auditor can have multiple assignments in an audit with different site/scheme/role allocations.
- Customer-facing routes do not automatically expose internal entities.
- Detailed Phase 1B modules can be added without changing the audit root or route hierarchy.
- No offline/sync-specific tables or UI assumptions are required for Phase 1.

## Related Documents

- [Phase 1B Audit Workspace](phase-1b-audit-workspace-architecture.md)
- [Database & Data Model](database-data-model-architecture.md)
- [Audit Lifecycle](../domain/audit-lifecycle.md)
