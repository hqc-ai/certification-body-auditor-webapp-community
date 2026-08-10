# Security Policy

**Primary author / architecture lead**  
Nguyễn Đăng Quang  
Lead Auditor ISO/IEC 27001, ISO/IEC 42001, ISO/IEC 27701  
Project Lead – AI Governance & AIMS Platform Development  
NQA Viet Nam

## Scope

This repository currently provides an architecture and database baseline. Security requirements become stricter when a runnable reference implementation accepts real audit or customer data.

## Security Principles

- Do not commit secrets, credentials, tokens, private URLs, or real customer data.
- Enforce customer visibility server-side; UI hiding is not authorization.
- Keep internal technical-review notes, competence data, and audit logs internal.
- Use least privilege for database and object-storage credentials.
- Use secure upload/download mechanisms for evidence files.
- Validate business state transitions on the server.
- Preserve material history for finding close/reopen, audit completion, report release, and review decisions.
- Future authentication should support clear auditor/customer/reviewer role boundaries.
- AI services must not receive confidential evidence unless deployment controls and data-processing rules explicitly permit it.

## Sensitive Audit Data

Production deployments may process confidential organization information, personal data, evidence, and certification records. Implementers are responsible for appropriate legal, contractual, information-security, privacy, retention, and access-control obligations.

## Reporting Vulnerabilities

Please report security issues privately to the project owner through the official NQA Viet Nam project contact channel selected for this repository. Do not publish exploit details or customer data in a public issue.

No email address or third-party vulnerability platform is invented in this Community package; the project owner should add the preferred security contact before public release.
