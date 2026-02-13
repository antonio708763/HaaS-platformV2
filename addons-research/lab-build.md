# Lab Build (Research Hardware)

Purpose:
Temporary research platform used to explore architecture, limitations, and workflows.

This hardware is **NOT representative of final client reference builds**.

This system exists to validate:

- GPU passthrough
- media acceleration behavior
- storage layouts
- VM-based service architecture

---

## Table of Contents

- [Host System](#host-system)
- [Components](#components)
  - [CPU](#cpu)
  - [Motherboard](#motherboard)
  - [BIOS / Firmware](#bios--firmware)
  - [RAM](#ram)
  - [GPU](#gpu)
  - [Networking](#networking)
  - [Storage (Physical)](#storage-physical)
  - [VM Storage](#vm-storage)
- [Notes](#notes)

---

## Host System

This lab system is used as the primary research node for HaaS-platform development.

---

## Components

### CPU

AMD Ryzen 3 2200G  
4 cores / 4 threads  
Integrated Radeon Vega Graphics

---

### Motherboard

Gigabyte B450M DS3H-CF

---

### BIOS / Firmware

AMI BIOS F2  
Release Date: 2018-08-08

---

### RAM

16 GB DDR4-2400  
4 × 4 GB DIMMs  
G.Skill F4-2400C17-4GNT

---

### GPU

#### Discrete GPU (Passthrough Device)

AMD/ATI Juniper PRO  
Radeon HD 6750  
PCI ID: `1002:68bf`

Used for:

- VM passthrough
- VAAPI hardware decode testing

#### Integrated GPU

AMD Radeon Vega (from Ryzen 3 2200G)

Not currently used for passthrough.

---

### Networking

NIC:

Realtek RTL8111/8168  
PCI ID: `10ec:8168`

Proxmox Bridge:

- `vmbr0`
- `nic0` enslaved into `vmbr0`

`vmbr0` acts as the primary LAN bridge for VMs.

---

### Storage (Physical)

#### sda

250 GB Western Digital SSD  
Contains Proxmox OS  
ZFS member

#### sdb

1 TB Western Digital HDD  
Bulk data / general storage

#### sdc

240 GB SSD  
Contains NTFS partitions  
Legacy Windows disk (not part of Proxmox storage pools)

---

### VM Storage

#### zd0

32 GB virtual disk  
Debian 12 VM system disk

Additional `zd*` devices:

ZVOL-backed virtual block devices (normal for ZFS usage).

---

## Notes

- Hardware is heterogeneous and partially legacy.
- GPU is legacy AMD (Terascale generation).
- Platform is intended for experimentation, not performance benchmarking.
- Results may differ from modern GPUs or enterprise hardware.
