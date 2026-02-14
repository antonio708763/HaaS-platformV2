# Backup Policy Standard (Client Track)

Purpose:  
Define standardized backup rules for all HaaS-platformV2 deployments.

This ensures:
- predictable recovery behavior
- consistent retention and storage usage
- client-ready reliability standards
- documented restore verification procedures

Scope:  
Client-ready standard track.

---

## Table of Contents

- [Overview](#overview)
- [Backup Philosophy](#backup-philosophy)
- [Backup Targets](#backup-targets)
- [Backup Storage Standard](#backup-storage-standard)
- [Backup Schedule Standard](#backup-schedule-standard)
- [Retention Standard](#retention-standard)
- [Backup Compression Standard](#backup-compression-standard)
- [Backup Verification Standard](#backup-verification-standard)
- [Restore Testing Standard (Mandatory)](#restore-testing-standard-mandatory)
- [Minimum Backup Requirements](#minimum-backup-requirements)
- [Recommended Backup Workflow](#recommended-backup-workflow)
- [Golden Rules](#golden-rules)
- [Notes](#notes)

---

## Overview

Backups are mandatory for all client deployments.

Without backups:
- hardware failure becomes catastrophic
- VM corruption requires full rebuild
- client trust is lost immediately

With backups:
- VMs can be restored quickly
- rebuild time is reduced from hours to minutes
- platform becomes supportable as a real service

---

## Backup Philosophy

The HaaS-platformV2 backup standard is built around:

- **nightly automated backups**
- **minimum 7-day retention**
- **restore testing after major changes**
- **dedicated backup storage (separate disk)**

Backups must be treated as part of the platform baseline, not an optional feature.

---

## Backup Targets

The following VMs must always be backed up:

| VM Role | Example VMID | Required |
|--------|--------------|----------|
| Golden Template | VM100 | Yes |
| Docker Host | VM200 | Yes |
| DNS VM | VM210 | Yes |
| Monitoring VM | VM220 | Yes |
| Any VM hosting client data | Any | Yes |

Any VM that provides critical infrastructure services is considered mandatory.

---

## Backup Storage Standard

Backups must be stored on a dedicated disk mounted to the Proxmox host.

Example mount point:

- `/mnt/backup`

Proxmox storage type must be `dir` storage.

Example Proxmox storage name:

- `backup-hdd`

Backups must not be stored on the same disk pool as production VM disks.

---

## Backup Schedule Standard

Standard backup schedule:

- **nightly backups**
- start time: **02:00** (local time)

Backups should run during low usage hours.

Example standard schedule:

- every day at 02:00

---

## Retention Standard

Minimum retention policy:

- **7 days minimum**
- `maxfiles 7` per VM

Recommended retention policy (production):

- 14 to 30 days (depending on disk size)

Retention must be enforced automatically.

---

## Backup Compression Standard

Standard compression method:

- `zstd`

Reasoning:
- fast compression
- strong compression ratio
- widely supported by Proxmox

---

## Backup Verification Standard

Backups are not considered valid until restore testing is performed.

At minimum:
- verify that the backup job runs successfully
- verify backup files exist on disk
- verify Proxmox reports no errors

Example verification commands:

    ls -lh /mnt/backup/dump/
    grep vzdump /var/log/syslog | tail -50

---

## Restore Testing Standard (Mandatory)

Restore testing is mandatory after:

- major baseline changes to VM100
- major stack deployments on VM200
- OS upgrades or kernel changes
- backup storage changes
- quarterly maintenance cycles (recommended)

Restore testing procedure:

1. Restore latest backup into a temporary VMID
2. Boot the restored VM
3. Confirm login works
4. Confirm networking works
5. Confirm services start correctly (if applicable)
6. Delete the temporary VM after validation

Example restore drill policy:

- restore VM100 backup into VM101
- restore VM200 backup into VM201

Restore testing is required for any deployment claiming “client-ready” status.

---

## Minimum Backup Requirements

To meet the client standard baseline:

- backups must run nightly
- retention must be enforced
- backups must be stored on a dedicated disk
- restore drill must be documented and performed at least once
- restore drill must be repeated after major changes

---

## Recommended Backup Workflow

Recommended baseline backup workflow:

1. Build VM100 golden template
2. Snapshot VM100 before major changes
3. Run manual backup after major change
4. Enable nightly scheduled backups
5. Perform restore drill
6. Clone VM200 and deploy services
7. Perform restore drill again after major deployments

---

## Golden Rules

- Backups are mandatory for all infrastructure VMs.
- Backups must run nightly with retention enabled.
- Backup storage must be physically separate from VM disks.
- Backups must be restore-tested after major changes.
- A backup that has never been restored is not trusted.
- Do not disable backups for “temporary” VMs if they hold important data.
- If backup storage fails, the platform is considered degraded until fixed.

---

## Notes

Example manual backup command:

    vzdump 100 --storage backup-hdd --compress zstd --mode snapshot

Example scheduled backup job:

    pvesh create /cluster/backup \
      --id nightly-vm100 \
      --storage backup-hdd \
      --mode snapshot \
      --compress zstd \
      --dow mon,tue,wed,thu,fri,sat,sun \
      --starttime 02:00 \
      --vmid 100 \
      --maxfiles 7

Backup job names should follow a predictable naming format:

- `nightly-vm100`
- `nightly-vm200`

Backups should be monitored manually until VM220 monitoring standard is deployed.
