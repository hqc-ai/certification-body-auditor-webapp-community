# Contributing

Thank you for considering a contribution to CB Auditor Webapp Community.

**Primary author / architecture lead**  
Nguyễn Đăng Quang  
Lead Auditor ISO/IEC 27001, ISO/IEC 42001, ISO/IEC 27701  
Project Lead – AI Governance and AIMS Platform Development  
NQA Viet Nam

## Contribution Principles

Contributions should improve generic, independently described auditing architecture or implementation while preserving professional judgement, traceability, and clear internal/customer boundaries.

### Welcome contributions

- architecture clarifications;
- PostgreSQL schema improvements that remain Phase-appropriate;
- validation/readiness rules;
- accessible web UI patterns for audit work;
- report projection/rendering patterns;
- test data and examples using fictional organizations;
- security improvements;
- responsible AI-assist patterns with human approval.

### Do not contribute

- customer confidential information;
- real certificate numbers or internal project identifiers;
- personal data copied from live audit systems;
- third-party proprietary screenshots, logos, UI assets, or source code;
- substantial copyrighted wording from commercial documentation;
- credentials, API keys, tokens, or private URLs;
- claims that the Community Edition grants or determines certification.

## Pull Request Checklist

1. Explain the problem and architectural rationale.
2. Keep terminology consistent with the Community Edition domain model.
3. Update documentation when schema or lifecycle behavior changes.
4. Add or update demo/test data using fictional identifiers only.
5. Confirm customer-facing DTOs do not expose internal-only data.
6. For AI features, preserve human approval, source traceability, and draft/final separation.
7. Confirm no third-party proprietary material has been introduced.

## Schema Changes

Any schema pull request should document:
- PK/FK changes;
- new uniqueness or deletion behavior;
- lifecycle implications;
- migration impact;
- whether multi-site, multi-scheme, and multi-assignment behavior remains supported.

## Attribution

Please preserve the project-owner and primary-author attribution in the main repository documentation. Contributor credits may be added without removing or obscuring the original architecture attribution.
