# Phase 1C GitHub Update Guide

This package is prepared as a **drop-in Community Edition update** for:

`hqc-ai/certification-body-auditor-webapp-community`

## Replace

- `README.md`
- `database/ERD.md`
- `docs/roadmap/community-roadmap.md`

## Add

- `docs/architecture/phase-1c-cb-operations-customer-portal.md`
- `docs/architecture/phase-1c-data-model-extension.md`
- `docs/domain/role-permission-model.md`
- `docs/domain/review-certification-workflow.md`
- `docs/domain/customer-portal-model.md`
- `database/phase-1c-extension.sql`
- `PHASE_1C_COMMUNITY_MIGRATION_REPORT.md`

## Do not upload

This package does not include the internal Phase 1C DOCX handoff files.

Do not upload source research screenshots or third-party product documentation into the public Community repository.

## Recommended commit message

```text
docs: add Community Phase 1C CB operations and customer portal architecture
```

## Suggested GitHub release note

```text
Community architecture update: Phase 1C

Adds a generic Certification Body operations layer around the existing auditor workflow:
- Technical Review
- Certification Decision
- Planner / Audit Coordinator
- Customer Portal
- Corrective-action response workflow
- Controlled document publication
- Role and segregation-of-duties model
- Phase 1C PostgreSQL extension
- Updated Mermaid architecture and ERD diagrams
```
