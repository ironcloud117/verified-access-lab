# ADR-001 — Zero trust access for unpatchable legacy web applications

| Field | Value |
|---|---|
| Status | Accepted |
| Date | 2026-10-12 |
| Deciders | Cloud architect (author), security, application owners |
| Related | [ADR-002](ADR-002-administrative-access-session-manager.md), [Technical debt register](../technical-debt-register.md) |

## Context

Several internal web applications run on deprecated PHP versions and outdated libraries, with little documentation.
They cannot be patched or replaced in the short term, but employees must keep using them from anywhere.
Exposing them publicly would make known vulnerabilities reachable by anyone.

Constraints: no change to the application, no public endpoint for the application, access decided per identity,
full audit trail, small team, everything as code.

## Options considered

1. **Patch or replace the applications.** Removes the root cause but needs time, budget and skills not available now.
2. **Internet-facing ALB + AWS WAF.** Simple, but WAF rules are signature based: unknown or logic flaws in unpatched code stay reachable.
3. **AWS Client VPN.** Mature, but grants network-level trust, needs client software and certificate management, and allows lateral movement once connected.
4. **Internet-facing ALB + OIDC authentication.** Cheap and simple identity gate, but the load balancer stays public and policies are coarse.
5. **AWS Verified Access.** Per-request evaluation of identity (and optionally device posture) through Cedar policies; the application stays in private subnets behind an internal ALB.

## Decision

Adopt **AWS Verified Access** in front of an **internal ALB**, with the corporate identity provider as OIDC trust provider
(Amazon Cognito in the proof of concept). Access rules are written as Cedar policies and managed in Terraform.

## Rationale

- Vulnerable code is never reachable without a successful authentication **and** a policy permit (verified: an authenticated but non-permitted user receives `403`).
- No public IP or public load balancer for the applications; the VPC has no internet route.
- Policies are code: reviewed, versioned and changed in place in seconds.
- Managed service: no VPN appliances or client software to operate.
- Option 1 remains the long-term target and is tracked as technical debt (TD-001).

## Consequences

**Positive**
- Strong reduction of attack surface without touching the applications.
- Uniform, auditable access model reusable for other internal applications.

**Negative / risks**
- Cost is per application per hour: to be compared with option 4 when many low-traffic applications are involved.
- Endpoint creation takes ~15 minutes; changes that force replacement (domain, certificate, subnets) cause downtime and require a planned change window.
- Access logging must be enabled and shipped to the central log account before production.
- Device posture checks (Jamf, CrowdStrike, etc.) are not covered by the PoC.

## Review triggers

- An application is modernised or decommissioned (close TD-001 for that application).
- More than ~10 applications in scope: re-evaluate cost against ALB + OIDC.
- Device-based policies become a requirement.
