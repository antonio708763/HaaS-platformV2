# Debian 12 Base VM (Service VM)

Purpose:
Baseline Debian 12 VM used to run containerized services (example: Immich) with predictable, reproducible configuration.

This VM is designed for **service hosting and GPU-assisted media acceleration testing**, including VAAPI workflows.

---

## Table of Contents

- [VM Overview](#vm-overview)
- [Virtualization Settings](#virtualization-settings)
- [Disks](#disks)
- [Networking](#networking)
- [Firmware and Machine Type](#firmware-and-machine-type)
- [CPU Type and Features](#cpu-type-and-features)
- [Boot and Startup](#boot-and-startup)
- [GPU Passthrough](#gpu-passthrough)
- [Guest Driver and Device Nodes](#guest-driver-and-device-nodes)
- [Validation Commands](#validation-commands)
- [Snapshot Rules](#snapshot-rules)
- [Notes](#notes)

---

## VM Overview

### VM Identity

- VMID: **900**
- Name: **debian12-base**
- OS type (Proxmox): `l26` (Linux 2.6+)
- Role: Service VM (Docker / application stacks)

---

## Virtualization Settings

### VM Resources

- CPU type: `host`
- Sockets: `1`
- Cores: `2`
- Memory: `2048 MB`
- Ballooning: disabled
- NUMA: disabled
- QEMU Guest Agent: enabled

---

## Disks

Storage backend: `local-zfs` (`rpool/data`)

Disks:

- `efidisk0`: `local-zfs:vm-900-disk-0`
  - OVMF EFI disk
  - Microsoft certificate + pre-enrolled keys enabled
- `scsi0`: `local-zfs:vm-900-disk-1` (32G)
  - `discard=on`
  - `iothread=1`

Controller:

- SCSI controller: `virtio-scsi-single`

Installation media:

- `ide2`: `debian-12.5.0-amd64-netinst.iso`

---

## Networking

- NIC model: VirtIO
- Bridge: `vmbr0`
- MAC address: `BC:24:11:1E:1B:10`
- Boot order places network after disks

---

## Firmware and Machine Type

- Firmware / BIOS: **OVMF (UEFI)**
- Machine type: **q35**

---

## CPU Type and Features

CPU configuration:

- `host`

This exposes host CPU features directly to the guest for maximum compatibility and performance.

---

## Boot and Startup

Boot order:

1. Primary disk (`scsi0`)
2. Installer ISO (`ide2`)
3. Network (`net0`)

---

## GPU Passthrough

GPU passthrough is configured via VFIO.

Passthrough devices:

- `hostpci0`: `01:00.0`
  - AMD/ATI Juniper PRO (Radeon HD 6750)
  - PCIe enabled (`pcie=1`)
- `hostpci1`: `01:00.1`
  - AMD HDMI audio device
  - PCIe enabled (`pcie=1`)

Machine type `q35` is required for proper PCIe passthrough behavior.

---

## Guest Driver and Device Nodes

Inside the Debian guest:

Virtual display adapter:

- QEMU Bochs VGA (`1234:1111`)
- Driver: `bochs-drm`

Passed-through GPU:

- AMD Juniper PRO (`1002:68bf`)
- Driver: `radeon`

Passed-through HDMI audio:

- Driver: `snd_hda_intel`

DRM device nodes:

- `/dev/dri/card0` — `root:video`
- `/dev/dri/card1` — `root:video`
- `/dev/dri/renderD128` — `root:render`

These nodes are mounted into containers for VAAPI access.

---

## Validation Commands

Run inside the Debian VM:

~~~bash
lspci -nnk | grep -A3 -E "VGA|Display|Audio"
ls -l /dev/dri
vainfo
~~~

---

## Snapshot Rules

Recommended snapshot workflow:

- Snapshot after base OS install
- Snapshot after Docker + Compose install
- Snapshot after GPU passthrough validation
- Snapshot after deploying major stacks (example: Immich)

---

## Notes

- This VM is intended for service hosting and GPU acceleration testing.
- VAAPI container workflows require correct `/dev/dri` permissions.
- Keep this VM configuration documented before cloning or scaling workloads.
