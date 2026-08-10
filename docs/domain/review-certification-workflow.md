# Technical Review & Certification Decision Workflow

## Purpose

Keep audit execution, independent technical review and independent certification decision as separate lifecycles.

An auditor recommendation is not a certification decision.

## Workflow

```mermaid
sequenceDiagram
    participant A as Auditor
    participant S as Audit Service
    participant R as Reviewer
    participant D as Decision Maker
    participant P as Publication

    A->>S: Submit completed audit
    S->>S: Validate readiness + lock submitted content
    S-->>R: Create/assign technical review

    alt Review returned
        R->>S: Return with mandatory comment
        S-->>A: Unlock authorized sections
        A->>S: Update and resubmit
        S-->>R: New review cycle / resubmission
    else Review accepted
        R->>S: Accept technical review
        S-->>D: Make audit eligible for certification decision
    end

    alt Decision hold / return
        D->>S: Hold or return with rationale
    else Decision approved
        D->>S: Approve certification decision
        S-->>P: Certificate becomes eligible for issue/publication
    end
```

## Technical Review States

- `PENDING`
- `IN_PROGRESS`
- `RETURNED`
- `ACCEPTED`

## Technical Review Data

- reviewer;
- audit;
- revision number;
- timestamps;
- review summary;
- checklist responses;
- action/comment history.

## Review Return Rule

A return must contain a comment and should identify the relevant section when practical, for example:

- findings;
- management summary;
- conclusions;
- statements;
- technical summary;
- documents.

Only authorized auditor-editable content should reopen.

## Certification Decision States

- `PENDING`
- `APPROVED`
- `RETURNED`
- `HOLD`
- `REJECTED`

## Certification Decision Types

- `GRANT`
- `MAINTAIN`
- `RENEW`
- `EXTEND`
- `REDUCE`
- `OTHER`

## Integrity Rules

- Decision cannot be approved until technical review is accepted.
- The accepted review used for the decision is referenced explicitly.
- Decision history is preserved by cycle/revision.
- Approval does not automatically publish a certificate.
- Publication is a separate controlled action.
