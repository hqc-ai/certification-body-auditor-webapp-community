# Audit Lifecycle

**Primary author / architecture lead**  
Nguyễn Đăng Quang  
Lead Auditor ISO/IEC 27001, ISO/IEC 42001, ISO/IEC 27701  
Project Lead – AI Governance and AIMS Platform Development  
NQA Viet Nam

## Principle

Audit completion is a validated business transition, not a free-form status edit. The exact operational labels may be configured later, but Phase 1 uses a simple lifecycle sufficient to demonstrate planning, execution, completion, reporting, and downstream review.

## Community Baseline States

```text
DRAFT
  |
  v
PLANNED
  |
  v
READY
  |
  v
IN_PROGRESS
  |
  v
READY_FOR_COMPLETION
  |  [readiness validation]
  v
COMPLETED
  |
  +--> report generation / publication
  |
  v
REPORTED

Technical Review is a separate object/lifecycle and does not need to replace Audit.status.
Finding follow-up may continue after COMPLETED or REPORTED.
```

## Transition Rules

| From | To | Typical rule |
|---|---|---|
| DRAFT | PLANNED | core organization, dates, site and scheme context defined |
| PLANNED | READY | required assignment/planning data complete |
| READY | IN_PROGRESS | audit execution started |
| IN_PROGRESS | READY_FOR_COMPLETION | execution content prepared for validation |
| READY_FOR_COMPLETION | COMPLETED | readiness checks pass and authorized actor confirms |
| COMPLETED | REPORTED | required report/output is generated/released |

Every state change should append `audit_status_history` with actor, timestamp, from/to state, and optional comment.

## Readiness Checks

The validation engine can evaluate:
- required dates, sites, schemes, scope, and team assignment;
- mandatory finding fields and evidence references;
- required management summary content;
- required conclusions and statements;
- all required site contexts complete;
- required historical open findings addressed;
- report/document prerequisites where configured.

Validation rules and authorization rules are distinct. Phase 1 can use a simplified actor model while retaining the service boundary for future role checks.

## Historical Audit Access

Previous audits, focus areas, and findings remain queryable. They are not copied wholesale into the current audit. Current screens use historical read models filtered by organization, site, scheme, or project context.

## Certification Boundary

An auditor's recommendation can be recorded as part of the conclusion/report context, but certification decision/authorization remains downstream and separate. The Community MVP must not imply that `COMPLETED` or `REPORTED` equals certification approval.
