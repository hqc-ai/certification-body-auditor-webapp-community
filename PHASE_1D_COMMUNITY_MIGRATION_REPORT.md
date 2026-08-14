# Phase 1D Community Migration Report

**Repository:** CB Auditor Webapp Community  
**Baseline date:** 14 August 2026  
**Migration:** Phase 1C → Phase 1D Customer Portal architecture

## Summary

Phase 1D separates the customer-facing portal into its own architecture phase while preserving Phase 1C as the Certification Body operations layer.

The migration is additive and does not remove the existing Phase 1C customer-portal hooks. Those hooks remain useful for customer corrective action, publication and CB-side authorization. Phase 1D adds the richer external-web experience and data model required for multi-company, multi-service, multi-site and year-based customer dashboards.

## Added files

- `docs/architecture/phase-1d-customer-portal-architecture.md`
- `docs/architecture/phase-1d-data-model-extension.md`
- `docs/domain/phase-1d-customer-portal-domain.md`
- `database/phase-1d-extension.sql`
- `database/PHASE_1D_ERD.md`
- `PHASE_1D_COMMUNITY_MIGRATION_REPORT.md`

## Updated files included in this patch

- `README.md`
- `docs/roadmap/community-roadmap.md`

## Phase reclassification

### Phase 1C

Now described primarily as:

- Reviewer / Technical Review;
- Certification Decision;
- Planner / Audit Coordinator;
- controlled publication;
- notifications/reminders;
- workflow history;
- segregation of duties;
- CB-side enablement of customer access and corrective-action workflow.

### Phase 1D

Now described as:

- customer web portal;
- email-linked customer identity boundary;
- organization membership/access;
- site/service authorization;
- Overview / My Services dashboard;
- year-based service progress;
- customer schedule view;
- audits, findings and corrective action;
- certificates and published documents;
- integration-ready Contracts, Financials and Trainings boundaries.

## Database extension

`database/phase-1d-extension.sql` adds:

- `service_engagements`
- `service_engagement_sites`
- `service_cycles`
- `audit_service_cycles`
- `audit_schedule_events`
- `customer_portal_site_access`
- `customer_portal_service_access`
- `portal_dashboard_preferences`
- `portal_activity_log`

It reuses rather than replaces:

- `users`
- `contacts`
- `customer_portal_access`
- `findings`
- `finding_customer_responses`
- `certifications`
- `audit_documents`
- `document_publications`

## Migration order

```bash
psql <database> < database/schema.sql
psql <database> < database/phase-1c-extension.sql
psql <database> < database/phase-1d-extension.sql
```

## Compatibility position

No destructive schema changes are required by this reference extension.

Existing deployments may continue to use Phase 1C customer access records. Phase 1D adds optional narrower site/service scopes and customer-service aggregation records.

## Public Community safeguards

This Phase 1D package intentionally excludes:

- proprietary customer-portal screenshots;
- third-party product UI reproduction;
- confidential customer data;
- third-party source code;
- protected implementation details;
- internal URLs or credentials.

The architecture captures generic conformity-assessment workflow patterns only.

## Donation section

The existing README donation content, bank details, USDT details and QR image paths are preserved in the updated README included with this patch.

