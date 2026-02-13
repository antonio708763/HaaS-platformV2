# Proxmox VE Host Setup

Purpose:
Document installation and configuration of the Proxmox host.

Goal:
Enable a clean reinstall of Proxmox and restoration of functionality with minimal guesswork.

---

## Table of Contents

- [Host Basics](#host-basics)
- [Installation Method](#installation-method)
- [Boot Mode](#boot-mode)
- [Storage Configuration](#storage-configuration)
- [ZFS Pool Status (Important)](#zfs-pool-status-important)
- [VM Storage Layout](#vm-storage-layout)
- [Snapshot Behavior and VFIO Considerations](#snapshot-behavior-and-vfio-considerations)
- [VFIO / GPU Passthrough Snapshot Limitation](#vfio--gpu-passthrough-snapshot-limitation)
- [Recovery Checklist](#recovery-checklist)
- [Notes](#notes)

---

## Host Basics

### Proxmox Version

- Proxmox VE: `pve-manager 9.1.1`
- Kernel: `6.17.2-1-pve`

---

## Installation Method

Proxmox VE installed from official ISO.

Installation media:

- USB flash drive
- Bootable Proxmox ISO written to USB
- Installed directly onto local SSD

---

## Boot Mode

- Legacy BIOS (non-UEFI)

---

## Storage Configuration

Proxmox storage configuration is defined in:

- `/etc/pve/storage.cfg`

---

### local (dir)

Type: Directory  
Path: `/var/lib/vz`

Content types:

- ISO images
- Container templates
- Backups
- Imports

Used primarily for:

- installation media
- backup artifacts

---

### local-zfs (zfspool)

Type: ZFS pool  
Pool: `rpool/data`

Content types:

- VM disk images
- container root filesystems

All VM disks are stored as ZFS zvols under this pool.

---

## ZFS Pool Status (Important)

ZFS pool:

- Pool name: `rpool`
- State: **DEGRADED**

Reported issues:

- Device: `ata-WDC_WDS250G2B0A...-part3`
- Errors: data errors detected
- Status: “too many errors”

Implications:

- Proxmox OS and all VM storage currently reside on a single SSD
- Disk health is degraded and presents a data integrity risk
- This configuration is acceptable for short-term research but **not suitable for production or client deployments**

Action item:

- Replace or reconfigure storage before standardizing this platform

---

## VM Storage Layout

VM disks are implemented as ZFS zvols.

Example for VMID 900:

- `rpool/data/vm-900-disk-0`
- `rpool/data/vm-900-disk-1`

Snapshot state volumes:

- `rpool/data/vm-900-state-*`

This confirms ZFS is being used for:

- VM disks
- snapshot metadata
- VM lifecycle management

---

## Snapshot Behavior and VFIO Considerations

Snapshots are taken with:

- RAM: **No**

This results in:

- disk-only snapshots
- no saved runtime or memory state

This is intentional and preferred when using VFIO passthrough.

---

## VFIO / GPU Passthrough Snapshot Limitation

Observed error:

- `VFIO migration is not supported in kernel`

Cause:

- Proxmox attempted to snapshot or save VM runtime state while a VFIO device (GPU) was attached
- Many passthrough devices do not support VFIO migration or VM state freezing

Resolution:

- Take snapshots only when the VM is stopped, or
- Use disk-only snapshots (RAM disabled)

Rule going forward:

- **Never attempt live snapshots or migrations on VMs with GPU passthrough**

---

## Recovery Checklist

Use this checklist after reinstalling Proxmox:

1. Confirm boot mode (Legacy BIOS vs UEFI)
2. Verify storage pools are present and imported
3. Confirm `local` and `local-zfs` exist in `/etc/pve/storage.cfg`
4. Verify ZFS pool health (`rpool` should not be degraded in production)
5. Restore VM backups and validate boot behavior
6. Confirm snapshot policies for passthrough workloads (disk-only snapshots)

---

## Notes

- Current storage configuration is acceptable for experimentation.
- Storage redundancy and disk health must be addressed before any client-facing deployment.
- VFIO passthrough imposes constraints on snapshot and migration workflows.
