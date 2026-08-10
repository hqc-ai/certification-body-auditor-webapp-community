# Phase 1C Community Migration Report

## 1. Source baseline

The Community Phase 1C documentation was derived from the internal Phase 1C architecture and data-model handoff dated 10 August 2026, combined with the existing Community Phase 1A/1B architecture baseline.

## 2. Content retained

The following generic architecture concepts were retained:

- one shared Audit object;
- role-aware workspaces;
- Reviewer / Technical Review;
- Certification Decision;
- Planner / Audit Coordinator;
- Customer Portal;
- customer corrective-action responses;
- controlled document publication;
- notifications and reminders;
- workflow history;
- role/assignment separation;
- segregation of duties;
- PostgreSQL-oriented relational extensions.

## 3. Content generalized

Organization-specific process language was converted into generic Certification Body terminology.

Examples:

| Internal concept | Community concept | Reason |
|---|---|---|
| Internal operational staff workspace | CB Staff Workspace | Generic conformity-assessment terminology |
| Approver | Certification Decision / Decision Maker | Preserve professional distinction from technical review |
| Customer-facing system name | Customer Portal | Vendor-neutral public term |
| External master system | Certification Management System | Generic extension point |
| Proprietary document availability model | Document Publication | Independent public architecture |
| Internal booking/project identifiers | Audit / project references | Remove internal implementation detail |

## 4. Content removed

The Community edition intentionally excludes:

- third-party brand names;
- third-party product names;
- screenshots;
- proprietary UI descriptions;
- internal URLs;
- internal system identifiers;
- real customer or auditor information;
- real certificate or project identifiers;
- vendor-specific infrastructure;
- substantial wording from third-party manuals.

## 5. Intellectual-property-sensitive material

No third-party screenshots, source code, proprietary schema, confidential implementation materials or protected product documentation are included.

Only independently described architecture, generic workflows and reusable domain concepts remain.

## 6. Community architectural assumptions

- Web-first application.
- PostgreSQL-compatible relational model.
- Object storage for binaries.
- Modular-monolith implementation is acceptable for Phase 1.
- Authentication may be simplified for the Community demo.
- Explicit user/role keys are still introduced in Phase 1C to avoid later structural redesign.
- Technical Review and Certification Decision are separate domain checkpoints.
- Customer publication is separate from internal approval and document storage.

## 7. Open design decisions

- exact technology stack for the reference UI/API;
- production identity provider;
- fine-grained permission framework;
- scheme-specific review checklist configuration;
- certificate template/rendering approach;
- automatic reminder scheduler;
- event bus vs in-process domain events;
- production migration tooling.

## 8. Recommended next implementation tasks

1. Apply/review the Phase 1C relational extension.
2. Implement user-role and audit-role authorization helpers.
3. Implement technical-review state transitions.
4. Implement Certification Decision state transitions.
5. Implement Customer Portal projections.
6. Implement versioned customer corrective-action responses.
7. Implement document publication checks.
8. Add transition-history transaction tests.
9. Add authorization tests for cross-customer isolation.
10. Seed demo actors and one end-to-end Community audit scenario.

## 9. Public-release checks

- [x] Generic CB terminology used.
- [x] No third-party brand is required to understand the architecture.
- [x] No screenshots included.
- [x] No real customer data included.
- [x] No real audit/certificate identifiers included.
- [x] Certification Decision is not described as an auditor action.
- [x] AI is advisory only.
- [x] Community documentation does not claim to provide certification services.
