# CB Auditor Webapp Community

An open reference architecture for modern web-based conformity-assessment and ISO management-system auditing.

**Project Owner:** HQC AI

**Author & Project Lead:**  
Nguyễn Đăng Quang  
Lead Auditor ISO/IEC 27001, ISO/IEC 42001, ISO/IEC 27701  
Project Lead – AI Governance and AIMS Platform Development

> Community Edition baseline: Phase 1 Community MVP, derived from the CB Auditor Webapp Phase 1A, Phase 1B, and Database/Data Model architecture handoffs dated 09 August 2026.

## Project Purpose

CB Auditor Webapp Community is an independent reference architecture and experimental platform for exploring web-first digital auditing. It is intended for developers, auditors, certification professionals, consultants, researchers, trainers, and contributors who want a practical domain model for structured conformity-assessment workflows.

The project explores how modern web technologies, structured audit data, and responsible AI can improve auditor productivity, audit consistency, evidence traceability, finding management, report generation, technical review, customer communication, and reuse of audit knowledge.

## Problem Being Solved

Auditing systems often mix planning data, audit execution notes, findings, customer responses, reports, reviewer records, and certification information into disconnected documents or tightly coupled screens. This makes traceability, reuse, reporting, and later system integration difficult.

This architecture treats the **Audit** as the central operational aggregate while keeping important lifecycles separate: findings, customer responses, technical review, certification governance, reporting, and future AI assistance. Reports are projections of structured data rather than the primary source of truth.

## Project Background

The architecture originates from practical auditing experience, business analysis of auditor workflows, and the design of a modern web-based auditor platform for Certification Body. Research into existing auditing software informed general workflow lessons, but this Community Edition is independently described and intentionally excludes proprietary interfaces, screenshots, wording, source code, confidential identifiers, and protected implementation details from third parties.

## Project Principles

- **Web-first:** server-backed web architecture; no offline synchronization engine in the Community MVP.
- **Modular:** clear domain boundaries even when implemented as a modular monolith.
- **Auditable:** material state changes and review decisions should be traceable.
- **Explainable:** business rules and system behavior should be understandable to auditors as well as engineers.
- **Structured-data first:** findings, summaries, conclusions, statements, evidence, and reviews are domain data, not one giant report blob.
- **Human-governed AI:** AI may draft or check; it does not replace professional auditor judgement.
- **Explicit visibility:** internal data and customer-visible output are intentionally separated.
- **Portable and API-friendly:** relational data, stable identifiers, and resource-oriented service boundaries.
- **Phase-appropriate simplicity:** avoid enterprise-scale complexity until it is justified.
- **Extensible:** do not hard-code one site, one scheme, one auditor, or one report language.

## Phase 1 Community MVP Scope

Phase 1 demonstrates the complete audit workflow and core data model without requiring authentication or enterprise integrations. The primary demonstration areas are:

1. Auditor input workspace
2. Audit planning and assignment information
3. Audit execution workspace
4. Focus area management
5. Findings management
6. Evidence management
7. Management summary
8. Audit conclusions
9. Auditor statements
10. Customer-visible audit output
11. Report generation structure
12. Technical review structure
13. Core relational database and data model

Authentication, MFA, offline synchronization, advanced analytics, enterprise certification-system integration, and production-grade customer identity are intentionally deferred.

## High-Level Architecture

```text
Browser / Web UI
       |
       v
Application API / BFF
       |
       +-- Audit Workspace Module
       +-- Findings & Follow-up Module
       +-- Evidence Module
       +-- Reporting Module
       +-- Customer Output Module
       +-- Technical Review Module (staged)
       +-- Certification Workflow Extension Point
       +-- AI Assist Extension Point (future)
       |
       v
PostgreSQL ---------------- Object Storage
(structured data)           (evidence / generated files)
```

The recommended Phase 1 implementation style is a **modular monolith** with explicit domain modules. This keeps deployment simple while preserving boundaries for future services.

## Major Application Modules

| Module | Purpose | Primary Phase 1 actors |
|---|---|---|
| Audit List / Work Queue | Entry point for scheduled and active audits | Auditor, Lead Auditor |
| Audit Overview | Customer, sites, schemes, team, dates, scope, status | Auditor, Lead Auditor |
| Focus Areas | Reusable assessment themes and structured summaries | Auditor |
| Findings & Follow-up | Finding creation, sharing, response, review, closure | Auditor, Customer |
| Evidence | Metadata and links to evidence/attachments | Auditor, Customer where published |
| Management Summary | Positive indications and improvement narrative | Lead Auditor |
| Conclusions | Controlled audit-level conclusion statements | Lead Auditor |
| Statements | Structured assessment topics and audit narrative | Auditor, Lead Auditor |
| Reporting | Generate customer-facing outputs from structured data | Lead Auditor |
| Technical Review | Independent downstream review structure | Technical Reviewer |
| Certification Workflow | Future downstream decision/authorization boundary | Certification personnel |
| AI Assist | Future draft/check support with human approval | Auditor |

## Domain Model Overview

```text
Organization
  +-- Site[]
  +-- Contact[]
  +-- Certification[]
  +-- AuditProject[]
        +-- Audit[]
              +-- AuditSite[] --------> Site
              +-- AuditScheme[] ------> Scheme
              +-- AuditAssignment[] --> Auditor
              +-- FocusArea[]
              +-- Finding[]
              |     +-- FindingResponse[]
              |     +-- Evidence[]
              +-- ManagementSummary[]
              +-- Conclusion
              +-- Statement[]
              +-- AuditDocument[]
              +-- AuditReport[]
              +-- TechnicalReview[]
              +-- AuditStatusHistory[]
```

See [Domain Model](docs/domain/domain-model.md), [Audit Lifecycle](docs/domain/audit-lifecycle.md), and [Database Architecture](docs/architecture/database-data-model-architecture.md).

## Repository Structure

```text
CB-Auditor-Webapp-Community/
├── README.md
├── assets/
│   └── donate-qr.png          # added manually by project owner before publication
├── docs/
│   ├── architecture/
│   │   ├── phase-1a-application-architecture.md
│   │   ├── phase-1b-audit-workspace-architecture.md
│   │   └── database-data-model-architecture.md
│   ├── domain/
│   │   ├── domain-model.md
│   │   ├── audit-lifecycle.md
│   │   ├── finding-lifecycle.md
│   │   └── report-model.md
│   └── roadmap/
│       └── community-roadmap.md
├── database/
│   ├── schema.sql
│   ├── seed-demo.sql
│   └── ERD.md
├── CONTRIBUTING.md
├── SECURITY.md
├── LICENSE-NOTE.md
└── COMMUNITY_MIGRATION_REPORT.md
```

## Quick Start (Placeholder)

The repository currently defines the architecture and database baseline. A reference application scaffold can be added in a later implementation step.

```bash
# Example future flow
cp .env.example .env
createdb nqa_auditor_community
psql cb_auditor_community < database/schema.sql
psql cb_auditor_community < database/seed-demo.sql
# install dependencies and start the future reference web application
```

Do not treat these commands as a complete production deployment procedure until an application stack and migration tooling are committed.

## Current Development Status

**Status:** Community architecture baseline / Phase 1 MVP design package.

This repository documents the agreed application, audit-workspace, lifecycle, reporting, and relational-data foundations. It does not claim that every roadmap module has already been implemented. Technical review, customer portal identity, certification workflow, AI assistance, analytics, and enterprise integrations remain staged or future capabilities.

## Roadmap

The proposed roadmap is maintained in [docs/roadmap/community-roadmap.md](docs/roadmap/community-roadmap.md):

- Phase 1 – Core Auditor Workspace
- Phase 2 – Authentication and multi-user operation
- Phase 3 – Customer Portal
- Phase 4 – Technical Review and certification workflow
- Phase 5 – AI-assisted auditing
- Phase 6 – Analytics, audit intelligence, and organizational knowledge

Later phases are proposals unless explicitly promoted into an approved architecture baseline.

## Contribution Guidance

Contributions are welcome when they preserve the project's independence, auditability, and professional-use principles. Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request. Do not submit confidential audit data, proprietary screenshots, third-party source code, customer information, real certificate identifiers, or copyrighted documentation extracts.

## ❤️ Support the Project

CB Auditor Webapp Community is developed as an open community initiative to explore better digital tools for professional auditing, conformity assessment and AI-assisted audit workflows.

If this project is useful to your work, research, training, or software development, you are welcome to support its continued development.

Community support helps with:

- continued development of the Auditor Webapp
- development of new audit workflow modules
- database and reporting improvements
- AI-assisted auditing research
- ISO/IEC 42001 and AI governance features
- documentation and community examples
- maintaining free and open community resources

### Donate

<!-- Project owner: manually add assets/donate-qr.png before publication. No QR image is generated by this repository package. -->

Bank transfer — Vietnam & International
Bank: Shinhan Bank Vietnam
Account holder: NGUYEN DANG QUANG
Account number: 0944659937
SWIFT/BIC: SHBKVNVX
Transfer reference: DONATE Auditor App

<p align="center">
  <img src="assets/bank-qr.jpg"
       alt="Support CB Auditor Webapp Community"
       width="280">
</p>

USDT — TRC20
Asset: USDT
Network: TRON — TRC20
Address: TPNDgQnemyVjjhAuwSPSJz37BCaQrUkaj9

<p align="center">
  <img src="assets/usdt-qr-trx.jpg"
       alt="Support CB Auditor Webapp Community"
       width="280">
</p>

Verify the receiving address and blockchain network carefully before transferring. Cryptocurrency transactions are generally irreversible.

Your support helps maintain the public edition, improve documentation, develop practical examples, and continue sharing useful resources.

Sharing knowledge creates value. Supporting the project helps that value continue.

Donations are voluntary and do not purchase consulting, certification, training, technical support, or guaranteed feature development.

**Thank you for supporting the development of open tools for the auditing and conformity-assessment community.**

Donation is completely optional and does not provide preferential access, certification benefits, audit outcomes, or influence over professional assessment activities.

## Disclaimer

CB Auditor Webapp Community is an independent project developed by Nguyen Dang Quang.

The architecture may incorporate general lessons learned from professional auditing practice and research into existing auditing systems. References to third-party auditing systems during the research and business-analysis process do not imply affiliation, endorsement, certification, approval or sponsorship.

No third-party proprietary software, source code, screenshots or confidential implementation materials are intended to be distributed as part of the Community Edition.

This repository is a software and architecture reference. It does not itself perform certification, grant certification status, make certification decisions, or replace applicable accreditation, scheme, legal, contractual, or professional requirements.

## Author and Project Attribution

**Primary author / architecture lead**  
Nguyễn Đăng Quang  
Lead Auditor ISO/IEC 27001, ISO/IEC 42001, ISO/IEC 27701  
Project Lead – AI Governance and AIMS Platform Development  
NQA Viet Nam

Please preserve this attribution when redistributing or transforming the architecture documentation, subject to the license terms selected by the project owner.
