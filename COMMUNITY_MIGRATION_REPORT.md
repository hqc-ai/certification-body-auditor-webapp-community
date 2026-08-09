# Community Migration Report

## 1. Source Documents Used

The Community Edition was transformed from three internal NQA Auditor Webapp architecture handoffs:

1. `CB_Auditor_Webapp_Phase_1A_ver09082026_Kiro_Architecture_Handoff`
2. `CB_Auditor_Webapp_Phase1B_ver09082026_Kiro_Architecture_Handoff`
3. `CB_Auditor_Webapp_Database_Data_Model_Architecture_Handoff_Phase1A_1B_ver09082026`

**Primary author / architecture lead**  
Nguyễn Đăng Quang  
Lead Auditor ISO/IEC 27001, ISO/IEC 42001, ISO/IEC 27701  
Project Lead – AI Governance and AIMS Platform Development  
NQA Viet Nam

## 2. Content Retained

- web-first, online-first Phase 1 principle;
- Audit as the core operational aggregate;
- multi-site, multi-scheme, multi-assignment architecture;
- structured findings, evidence, summaries, conclusions, and statements;
- separate finding/customer-response lifecycle;
- explicit customer-visible vs internal data boundary;
- independent technical-review lifecycle;
- structured data -> report renderer principle;
- PostgreSQL relational model with object-storage boundary;
- future-ready but non-dependent AI assistance with human approval;
- extension points for authentication, competence, customer portal, and certification workflows.

## 3. Content Generalized

Organization-specific workflow labels and UI-specific presentation details were converted to generic conformity-assessment terminology. Highly detailed certification-governance features were represented as extension points where they were not required for the Community MVP.

## 4. Content Renamed

| Internal Concept | Community Concept | Transformation Reason |
|---|---|---|
| Customer / Account master | Organization | Generic auditee/legal-entity terminology |
| Customer Site | Site | Removes organization-specific naming while preserving relationship |
| Customer Contact | Contact | Generic domain term |
| Auditor App / detailed proprietary workspace reference | Auditor Workspace | Independent community terminology |
| Customer certification portal references | Customer Portal / Customer-visible output | Removes third-party product naming |
| Service/back-office certification platform references | External Certification Management System | Generic integration boundary |
| Vendor-specific technical code labels | Technical / industry classification | Avoid proprietary code-system terminology |
| Vendor-specific audit event abbreviations | Configurable audit/programme event types | Keep domain principle without copying labels |
| Vendor-specific review/authorization queue labels | Technical Review / Certification Workflow | Generic assurance terminology |
| customers/customer_sites/customer_contacts | organizations/sites/contacts | Public schema normalization and neutral terminology |
| documents | evidence + audit_documents | Clearer separation of audit evidence from general file/output metadata |

## 5. Content Removed for Public Release

- third-party brand names and logos;
- third-party screenshots and proprietary UI references;
- internal URLs and system endpoints not needed for generic architecture;
- real customer/auditee details;
- real auditor/customer representative personal information;
- real audit/project/certificate identifiers;
- vendor-specific implementation technologies that were only research references;
- substantial wording from third-party documentation.

## 6. Third-Party References Removed

Research-source references and product-specific labels were removed from the public architecture files. The public README retains only a general disclaimer that professional practice and research into existing auditing systems informed architectural lessons and that this does not imply affiliation, endorsement, certification, approval, or sponsorship.

## 7. Potential Intellectual-Property-Sensitive Content Removed

No copied proprietary screenshots, UI assets, documentation extracts, source code, confidential field values, or product-specific implementation designs are intentionally included. Generic workflow patterns—such as finding response, technical review, report rendering, and many-to-many audit relationships—are independently expressed.

## 8. Architectural Assumptions

- Community MVP is online-first and does not need offline synchronization.
- Authentication can be deferred while actor references remain future-ready.
- PostgreSQL is the reference relational database.
- Object storage is used for evidence and generated files.
- State names in the schema are reference values and can become configurable later.
- Technical review is architecture-ready but not required to be fully implemented in the first UI milestone.
- Certification decision/authorization is downstream from auditor recommendation.
- AI is optional support and never an autonomous professional decision-maker.

## 9. Open Design Decisions

- final open-source license;
- production authentication/identity provider;
- exact NQA Viet Nam operational status/category vocabulary;
- report template engine and PDF/DOCX tooling;
- object-storage provider and retention policy;
- future certification-management integration contract;
- whether competence remains a lightweight master record or becomes assignment-context evaluation;
- multilingual data strategy;
- notification mechanism for finding follow-up;
- AI provenance schema and approved deployment controls.

## 10. Recommended Next Implementation Tasks

1. Initialize the Git repository and add the selected `LICENSE`.
2. Run `database/schema.sql` against a local PostgreSQL instance.
3. Validate `database/seed-demo.sql` and build basic CRUD integration tests.
4. Scaffold a modular monolith with Audit Workspace, Findings, Reporting, and Customer Output modules.
5. Implement Audit List and Audit Overview read models.
6. Implement finding lifecycle as explicit server-side actions plus history records.
7. Implement evidence metadata + object-storage abstraction.
8. Implement readiness validation before audit completion.
9. Build a customer-safe report projection and simple HTML report renderer.
10. Add authentication only after the single-user Phase 1 workflow is stable.
11. Add Technical Review as a separate downstream workflow.
12. Add AI assistance only after audit data, evidence, and human approval controls are stable.

## Final Public-Release Checks

- [x] No third-party branding appears in generated repository files.
- [x] No third-party screenshots are included.
- [x] No real customer information is included.
- [x] No confidential project/certificate identifiers are included.
- [x] NQA Viet Nam is identified as project owner.
- [x] Nguyễn Đăng Quang is identified as author/project lead.
- [x] SQL entity names are aligned with the Community architecture documentation.
- [x] Phase 1A, Phase 1B, and database concepts use consistent terminology.
- [ ] Project owner to add `assets/donate-qr.png` manually before publication.
- [ ] Project owner to select and add the final `LICENSE` file before publication.
