Public DNS (Cloudflare):
- photos/status/vault → public IP
- traefik/adguard → NXDOMAIN

Internal DNS (AdGuard):
- *.sotoprivatecloud.com → 192.168.1.24
- adguard.sotoprivatecloud.com → 192.168.1.43


Traefik Dashboard:
- EntryPoint: admin (8443)
- LAN-only via:
  - ipAllowList middleware
  - iptables (INPUT + DOCKER-USER)
- BasicAuth enabled
- Not present in public DNS


INPUT:
- ACCEPT established
- ACCEPT 192.168.1.0/24 → 8443
- DROP all others → 8443

DOCKER-USER:
- ACCEPT LAN → 8443
- DROP others → 8443


ACME: DNS-01 via Cloudflare
Certificates valid for:
- public services
- internal-only services (even if NXDOMAIN externally)


# Internal resolution works
nslookup traefik.sotoprivatecloud.com → 192.168.1.24

# Public resolution blocked
dig traefik.sotoprivatecloud.com @1.1.1.1 → NXDOMAIN

# Dashboard requires auth
curl → 401

# Services reachable
photos/status/vault → 200



