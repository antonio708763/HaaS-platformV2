# Network Validation Checklist

Purpose:  
This document provides a standardized validation procedure to confirm that a deployed HaaS network is functioning correctly.

This checklist is used for:
- Post-deployment verification
- Troubleshooting baseline
- Client handoff validation

---

## Table of Contents

- [Pre-Validation Requirements](#pre-validation-requirements)
- [Phase 1 - Basic Connectivity](#phase-1---basic-connectivity)
- [Phase 2 - DHCP Validation](#phase-2---dhcp-validation)
- [Phase 3 - DNS Validation](#phase-3---dns-validation)
- [Phase 4 - VLAN Isolation](#phase-4---vlan-isolation)
- [Phase 5 - NAT Enforcement](#phase-5---nat-enforcement)
- [Phase 6 - Service Access](#phase-6---service-access)
- [Phase 7 - Logging Verification](#phase-7---logging-verification)
- [Pass Criteria](#pass-criteria)
- [Notes](#notes)

---

## Pre-Validation Requirements

- All VLANs configured
- DHCP enabled on all VLANs
- AdGuard running and reachable (192.168.20.53)
- Firewall rules applied
- NAT rules applied

---

## Phase 1 - Basic Connectivity

For each VLAN:

- [ ] Device connects successfully
- [ ] IP address assigned
- [ ] Gateway reachable (ping VLAN gateway)
- [ ] Internet reachable (ping 8.8.8.8)

---

## Phase 2 - DHCP Validation

On client:

- [ ] IP is within correct VLAN range
- [ ] Gateway matches VLAN gateway
- [ ] DNS = AdGuard (192.168.20.53)

---

## Phase 3 - DNS Validation

### Test 1: Normal DNS

- [ ] Browse to website (e.g. youtube.com)
- [ ] DNS resolution works

---

### Test 2: Manual DNS Bypass

Set client DNS manually:

- 8.8.8.8
- 1.1.1.1

Expected:

- [ ] DNS fails OR is redirected
- [ ] Websites do NOT load (if blocked)
- [ ] OR still resolve via AdGuard (if redirected)

---

## Phase 4 - VLAN Isolation

From each VLAN:

- [ ] Cannot ping other VLAN gateways
- [ ] Cannot access internal services (unless explicitly allowed)

Example:

- IoT → Trusted ❌
- Guest → Servers ❌

---

## Phase 5 - NAT Enforcement

- [ ] DNS requests always hit AdGuard
- [ ] No direct DNS to external resolvers

Verification:

- Check OPNsense logs
- Confirm traffic redirected to 192.168.20.53

---

## Phase 6 - Service Access

Verify internal services:

- [ ] AdGuard reachable (192.168.20.53)
- [ ] Proxmox reachable (if in SERVERS VLAN)
- [ ] Docker services reachable

---

## Phase 7 - Logging Verification

Navigate:

Firewall → Log Files → Live View

Verify:

- [ ] RFC1918 blocks appear
- [ ] Public DNS blocks appear
- [ ] DoH blocks appear (if configured)
- [ ] No excessive log noise

---

## Pass Criteria

Deployment is considered successful when:

- [ ] All VLANs receive correct IP
- [ ] Internet works on all VLANs
- [ ] DNS is enforced through AdGuard
- [ ] VLAN isolation is functioning
- [ ] Logs show expected behavior
- [ ] No manual DNS bypass possible

---

## Notes

- Always validate one VLAN at a time
- Use wired connection for testing when possible
- Keep OPNsense console accessible during validation
- Document any deviations or custom rules
