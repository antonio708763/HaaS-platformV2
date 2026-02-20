# Traefik Admin Plane -- LAN-Only Architecture

**Status:** Production\
**Version Milestone:** v2.0\
**Last Updated:** 2026-02-19\
**Scope:** VM200 -- Reverse Proxy Stack

------------------------------------------------------------------------

## 1. Purpose

The Traefik dashboard is permanently restricted to **LAN-only access**.

It is:

-   Not publicly resolvable\
-   Not reachable from WAN\
-   Protected by IP allowlist\
-   Protected by Basic Authentication\
-   Enforced by host firewall rules\
-   Served with valid TLS

This document defines the security architecture of the admin plane.

------------------------------------------------------------------------

## 2. Network Architecture Overview

  Plane                   Port   Access      DNS Visibility
  ----------------------- ------ ----------- -------------------
  Public Services         443    WAN + LAN   Public DNS
  Admin Plane (Traefik)   8443   LAN-only    Internal DNS only

------------------------------------------------------------------------

## 3. DNS Design

### 3.1 Public DNS (Cloudflare)

-   `traefik.sotoprivatecloud.com` → NXDOMAIN\
-   No public A or CNAME record exists.

Verification:

``` bash
dig traefik.sotoprivatecloud.com @1.1.1.1
```

Expected result:

    status: NXDOMAIN

------------------------------------------------------------------------

### 3.2 Internal DNS (AdGuard)

-   `traefik.sotoprivatecloud.com` → `192.168.1.24`

Verification:

``` bash
dig +short traefik.sotoprivatecloud.com @192.168.1.43
```

Expected result:

    192.168.1.24

------------------------------------------------------------------------

## 4. Traefik EntryPoint Configuration

### 4.1 Static Configuration (`traefik.yml`)

``` yaml
entryPoints:
  web:
    address: ":80"
  websecure:
    address: ":443"
  admin:
    address: ":8443"
```

------------------------------------------------------------------------

### 4.2 Docker Port Binding

``` yaml
ports:
  - "80:80"
  - "443:443"
  - "192.168.1.24:8443:8443"
```

Important:

-   Binding to `192.168.1.24` prevents exposure on all interfaces.
-   Port 8443 is not bound to `0.0.0.0`.

------------------------------------------------------------------------

## 5. Middleware Security Stack

### 5.1 Router Configuration

``` yaml
http:
  routers:
    traefik-dashboard:
      rule: "Host(`traefik.sotoprivatecloud.com`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))"
      entryPoints:
        - admin
      service: api@internal
      middlewares:
        - dashboard-lan-only
        - dashboard-auth
        - security-headers@file
      tls:
        certResolver: letsencrypt
        options: modern@file
```

------------------------------------------------------------------------

### 5.2 Middleware Order (Critical)

1.  `dashboard-lan-only` (IP allowlist)
2.  `dashboard-auth` (BasicAuth)
3.  `security-headers@file`

IP restriction is evaluated before authentication.

------------------------------------------------------------------------

### 5.3 IP Allowlist

``` yaml
dashboard-lan-only:
  ipAllowList:
    sourceRange:
      - "192.168.1.0/24"
      - "127.0.0.1/32"
```

------------------------------------------------------------------------

### 5.4 Basic Authentication

Passwords are generated using bcrypt:

``` bash
htpasswd -nbB admin 'STRONG_PASSWORD'
```

The generated hash is placed in:

    /srv/stacks/reverse-proxy/dynamic/traefik-dashboard.yml

------------------------------------------------------------------------

## 6. TLS Configuration

-   Certificate issued via Let's Encrypt
-   DNS challenge provider: Cloudflare
-   Resolver: `letsencrypt`
-   Key type: `EC256`

Validation command:

``` bash
openssl s_client -connect 192.168.1.24:8443 -servername traefik.sotoprivatecloud.com
```

------------------------------------------------------------------------

## 7. Secret Management

### 7.1 Environment File

Location:

    /srv/stacks/reverse-proxy/.env

Permissions:

    -rw-r----- root docker

Contents:

    TRAEFIK_ACME_EMAIL=...
    CF_DNS_API_TOKEN=...

The file is referenced in `docker-compose.yml` via:

``` yaml
env_file:
  - .env
```

Secrets are not stored in `docker-compose.yml`.

------------------------------------------------------------------------

## 8. Host Firewall Enforcement

### 8.1 INPUT Chain Rules

``` bash
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -s 192.168.1.0/24 -p tcp --dport 8443 -j ACCEPT
-A INPUT -p tcp --dport 8443 -j DROP
```

Effect:

-   Only LAN subnet can reach port 8443
-   All other sources are dropped
-   DNS misconfiguration cannot expose admin plane

------------------------------------------------------------------------

### 8.2 DOCKER-USER Rules (Defense-in-Depth)

``` bash
-A DOCKER-USER -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A DOCKER-USER -s 192.168.1.0/24 -p tcp --dport 8443 -j ACCEPT
-A DOCKER-USER -p tcp --dport 8443 -j DROP
```

------------------------------------------------------------------------

### 8.3 Persistence

Firewall rules are persisted via:

``` bash
netfilter-persistent save
```

------------------------------------------------------------------------

## 9. Verification Checklist

  Test                                  Expected Result
  ------------------------------------- --------------------------
  Public DNS query                      NXDOMAIN
  Internal DNS query                    192.168.1.24
  LAN access                            401 → 200 after login
  WAN access                            Connection refused
  TLS certificate                       Valid Let's Encrypt cert
  Firewall rule persists after reboot   Yes

------------------------------------------------------------------------

## 10. Security Posture Summary

The Traefik admin plane is secured via:

-   Split-DNS isolation
-   Host-level firewall enforcement
-   Traefik IP allowlist
-   Bcrypt BasicAuth
-   TLS encryption
-   Secret separation via `.env`
-   Docker privilege minimization

This configuration ensures the admin surface is permanently LAN-only and
not internet exposed.
