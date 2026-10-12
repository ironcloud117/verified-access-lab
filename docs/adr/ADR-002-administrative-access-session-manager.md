# ADR-002 — Administrative access to isolated instances with Session Manager

| Field | Value |
|---|---|
| Status | Proposed |
| Date | 2026-10-12 |
| Deciders | Cloud architect (author), operations, security |
| Related | [ADR-001](ADR-001-zero-trust-access-for-legacy-apps.md) |

## Context

ADR-001 protects **user** access to the applications. Operators still need **shell access to the servers** for maintenance,
log inspection and service restarts. The VPC has no internet route, and the legacy servers must not expose additional ports.

## Options considered

1. **SSH through a bastion host.** Familiar, but adds a public host, key management and an open port 22.
2. **Client VPN + SSH.** Reuses existing tools, but keeps network-level trust and SSH keys.
3. **AWS Systems Manager Session Manager.** Shell access over the SSM agent, authorised by IAM, no inbound ports, no keys, sessions logged.

## Decision (proposed)

Use **Session Manager**, reached through interface VPC endpoints (`ssm`, `ssmmessages`, `ec2messages`) since the VPC has no internet route.
The instance role with `AmazonSSMManagedInstanceCore` is already in place in the PoC.

## Consequences

**Positive**
- No inbound ports, no bastion, no SSH keys to rotate.
- Access granted and revoked through IAM; every session can be logged to S3 / CloudWatch Logs.

**Negative / risks**
- Three interface endpoints per VPC (per AZ) add a fixed hourly cost; a shared endpoint VPC can reduce it at scale.
- The SSM agent must be supported by the legacy operating system; very old systems may need a compatibility check.

## Next step

Add the three interface endpoints to the Terraform stack and test a session from the console, then move this ADR to Accepted.
