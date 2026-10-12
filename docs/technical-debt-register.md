# Technical debt register

Debt accepted consciously, with an owner, a reason and an exit condition. Each entry links to the decision that created it.

| ID | Item | Reason accepted | Risk | Compensating controls | Owner | Exit trigger | Review | Status |
|---|---|---|---|---|---|---|---|---|
| TD-001 | Legacy web apps on deprecated PHP and libraries, not patchable | No budget, skills or documentation to modernise in the short term ([ADR-001](adr/ADR-001-zero-trust-access-for-legacy-apps.md)) | High: known vulnerabilities in application code | Verified Access (identity + Cedar policy per request), private subnets, no internet route, chained security groups | Application owner | Modernisation or decommissioning of each app | Quarterly | Open |
| TD-002 | No centralised access logging in the PoC | PoC scope | Medium: no audit trail | None in PoC | Cloud architect | Verified Access logs enabled and shipped to log archive account | Before production | Open |
| TD-003 | No device posture checks | Not required for PoC | Medium: unmanaged devices can access with valid credentials | Strong IdP authentication (MFA in production) | Security | Device trust provider integrated | Next iteration | Open |
| TD-004 | Administrative access path not implemented | Out of PoC scope ([ADR-002](adr/ADR-002-administrative-access-session-manager.md)) | Low in PoC, high in production | No inbound ports at all | Operations | Session Manager endpoints deployed and tested | Next iteration | Open |

## How to use it

- Every **Accepted** decision that leaves a known gap creates an entry here.
- Entries are reviewed on the stated cadence; the status moves to *Closed* only when the exit trigger is met.
- Items that relate to SaaS products without SSO or audit capabilities follow the same format: reason, compensating controls, exit trigger (vendor roadmap or contract renewal).
