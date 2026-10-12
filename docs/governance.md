# How this work maps to TOGAF and ITIL

A light mapping, to show where each artifact of this repository would sit in an enterprise process. Not a full framework implementation.

## TOGAF ADM

| ADM phase | In this repository |
|---|---|
| A — Architecture Vision | The request and constraints (README, sections 1–2) |
| B/C/D — Business, Information Systems, Technology Architecture | Target architecture diagram and component list (README, section 4) |
| E — Opportunities and Solutions | Options considered and decision flow (README, section 3; ADR-001) |
| F — Migration Planning | Terraform stack as the implementation plan; variants and next steps (ADR-002) |
| G — Implementation Governance | Tests performed against the decision (README, section 6) |
| H — Architecture Change Management | Review triggers in the ADRs, technical debt register |
| Architecture Repository | `docs/adr/` and `docs/technical-debt-register.md` |

## ITIL change management

- **Standard change:** Cedar policy updates (in-place, ~1 second, no downtime) — pre-approved, peer-reviewed pull request.
- **Normal change:** anything that replaces the Verified Access endpoint (domain, certificate, subnets): ~15 minutes of unavailability, needs impact assessment, change window and rollback plan. Detect it in `terraform plan` (`must be replaced`).
- **Evidence for the change record:** the `terraform plan` output, the ADR reference and the test results.
