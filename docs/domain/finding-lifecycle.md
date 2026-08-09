# Finding Lifecycle

**Primary author / architecture lead**  
Nguyễn Đăng Quang  
Lead Auditor ISO/IEC 27001, ISO/IEC 42001, ISO/IEC 27701  
Project Lead – AI Governance and AIMS Platform Development  
NQA Viet Nam

## Purpose

A finding is a first-class, structured audit object. Its lifecycle can extend beyond audit execution, especially when customer correction, root-cause analysis, corrective action, and auditor review are required.

## Baseline Lifecycle

```text
DRAFT
  |
  v
OPEN
  |
  | share/publish to customer
  v
SHARED
  |
  | customer submits response
  v
RESPONSE_RECEIVED
  |
  v
UNDER_REVIEW
  |  | \--> NEEDS_MORE_RESPONSE ----> RESPONSE_RECEIVED
  |
  +----> ACCEPTED
           |
           | validated close action
           v
         CLOSED

CLOSED --(configured reopen rule)--> REOPENED --> OPEN
```

## Business Rules

- `finding_no` is immutable after creation except controlled administrative correction.
- A finding records audit context and, where applicable, site, scheme, and focus area.
- Finding statement and objective evidence are separate concepts.
- Customer/auditee responses are versioned rows in `finding_responses`.
- Each status transition is appended to `finding_status_history`.
- Closing and reopening are validated actions.
- Customer sharing/publication is explicit and does not expose unrelated internal data.
- Finding follow-up can continue after the audit is completed.

## Finding Response Model

A response version may include:
- correction / containment;
- root cause;
- corrective action;
- customer comment;
- submission metadata;
- linked evidence;
- auditor review comment/result.

A resubmission creates a new response version rather than overwriting the previous one.

## Suggested Actions/API

```text
POST /audits/{auditId}/findings
PATCH /findings/{findingId}
POST /findings/{findingId}/share
POST /findings/{findingId}/responses
POST /findings/{findingId}/reviews
POST /findings/{findingId}/close
POST /findings/{findingId}/reopen
```

These endpoints express business actions and are preferable to allowing arbitrary direct status patches.

## AI Assistance

AI may propose a finding draft from auditor notes, selected scheme, and audit context. The draft must be reviewed/edited by a human auditor before it becomes the authoritative finding. AI must not bypass category validation, numbering, evidence linkage, lifecycle rules, or professional judgement.
