# HaaS-platformV2
Polished version of Haas
# VM100 Golden Template (Debian 12 Baseline)

## Purpose
This VM is the standardized **Debian 12 golden template** used for all client-ready deployments.

It is designed to be:
- hardened
- stable
- recoverable
- cloneable

VM100 is not intended to run production workloads directly.  
Instead, it serves as the baseline image for all future VM builds.

---

## This VM Validates
This template exists to validate:

- UEFI boot stability under Proxmox (OVMF)
- Serial console recovery access
- SSH key authentication baseline
- Fail2Ban protection for SSH brute-force attempts
- QEMU Guest Agent integration
- Backup + restore workflow reliability

---

## Table of Contents

- [VM Identity](#vm-identity)
- [Proxmox Configuration](#proxmox-configuration)
- [Storage Layout](#storage-layout)
- [Baseline Packages](#baseline-packages)
- [Services Enabled](#services-enabled)
- [Security Baseline](#security-baseline)
  - [SSH Hardening](#ssh-hardening)
  - [Fail2Ban](#fail2ban)
- [Operations & Reliability](#operations--reliability)
  - [Serial Console Configuration](#serial-console-configuration)
  - [UEFI Boot Repair Notes](#uefi-boot-repair-notes)
  - [Permanent Fix for /run/sshd](#permanent-fix-for-runsshd)
- [Backup & Restore Standard](#backup--restore-standard)
- [Snapshot Policy](#snapshot-policy)
- [Template Conversion](#template-conversion)
- [Clone Procedure](#clone-procedure)
- [Notes](#notes)

---

## VM Identity

| Field | Value |
|------|-------|
| VMID | 100 |
| Name | debian12-base-restored |
| OS | Debian GNU/Linux 12 (Bookworm) |
| Role | Golden Template |
| Purpose | Standard baseline for all clones |

---

## Proxmox Configuration

| Setting | Value |
|--------|-------|
| BIOS | OVMF (UEFI) |
| Machine | q35 |
| Boot Order | scsi0 |
| Storage | ZFS-backed |
| Secure Boot | Disabled (`pre-enrolled-keys=0`) |

Secure Boot is intentionally disabled to avoid shim/key enrollment issues during recovery and cloning.

---

## Storage Layout

| Disk | Type | Purpose |
|------|------|---------|
| scsi0 | ZVOL / ZFS | Debian OS disk |
| efidisk0 | ZVOL / ZFS | EFI variables disk |

---

## Baseline Packages

### Required Packages
- `openssh-server`
- `qemu-guest-agent`
- `fail2ban`
- `sudo`
- `curl`
- `vim` or `nano`

### Optional Recommended Packages
- `htop`
- `net-tools`
- `ca-certificates`

---

## Services Enabled

Services expected running:
- `ssh.service`
- `qemu-guest-agent.service`
- `fail2ban.service`

Verification:

```bash
systemctl status ssh --no-pager
systemctl status qemu-guest-agent --no-pager
systemctl status fail2ban --no-pager
```

---

## Security Baseline

### SSH Hardening
SSH goals:

- SSH must work immediately after clone
- SSH keys preferred
- Password authentication disabled for production workloads

Validation:

```bash
sudo sshd -t
sudo systemctl restart ssh
sudo systemctl status ssh --no-pager
```

### Fail2Ban
Fail2Ban is used to automatically ban brute-force SSH attempts.

Install and enable:

```bash
sudo apt update
sudo apt install -y fail2ban
sudo systemctl enable --now fail2ban
```

Verify jail status:

```bash
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

Expected:

- Jail list includes sshd
- service is active
- bans are tracked properly

---

## Operations & Reliability

### Serial Console Configuration
Serial console is required for recovery when SSH/networking fails.

This enables Proxmox access via:

```bash
qm terminal 100
```

Guest expectation:

- serial getty running on ttyS0

Verify inside VM:

```bash
systemctl status serial-getty@ttyS0.service --no-pager
```

### UEFI Boot Repair Notes
UEFI boot problems were observed during the VM recovery process.

Fix actions performed:

Verified EFI loader exists:

```bash
/boot/efi/EFI/debian/shimx64.efi
/boot/efi/EFI/debian/grubx64.efi
```

Reinstalled bootloader packages:

```bash
sudo apt update
sudo apt install --reinstall grub-efi-amd64 shim-signed
sudo update-grub
```

Disabled Secure Boot keys on Proxmox EFI disk.

This resolved:

- boot loops
- “No bootable device”
- missing EFI boot entry issues

### Permanent Fix for /run/sshd
Issue encountered:

`ssh.service` failed with:

```bash
Missing privilege separation directory: /run/sshd
```

Permanent fix implemented using systemd tmpfiles rule.

Create file:

```bash
sudo tee /etc/tmpfiles.d/sshd.conf >/dev/null <<'EOF'
d /run/sshd 0755 root root -
EOF
```

Apply immediately:

```bash
sudo systemd-tmpfiles --create /etc/tmpfiles.d/sshd.conf
ls -ld /run/sshd
```

Verify:

```bash
sudo sshd -t
sudo systemctl restart ssh
sudo systemctl status ssh --no-pager
```

This ensures SSH works after reboot and after cloning.

---

## Backup & Restore Standard
Backups are performed from Proxmox using `vzdump`.

Backup storage target:

- `backup-hdd`
- mounted at `/mnt/backup`

Manual backup:

```bash
vzdump 100 --storage backup-hdd --compress zstd --mode snapshot
```

Nightly backup job:

- Configured via Proxmox cluster backup scheduler
- retention: 7 backups

---

## Snapshot Policy
Snapshots are used only for temporary rollback testing.

Snapshots must be deleted before converting VM100 into a template.

List snapshots:

```bash
qm listsnapshot 100
```

Delete snapshot:

```bash
qm delsnapshot 100 <snapshot-name>
```

---

## Template Conversion
VM100 must meet these requirements before templating:

- boots cleanly
- SSH functional
- serial console functional
- fail2ban operational
- qemu-guest-agent running
- no snapshots exist

Convert to template:

```bash
qm template 100
```

---

## Clone Procedure
Clone VM100 into a new VM:

```bash
qm clone 100 200 --name docker-host-01 --full 1
```

After clone tasks:

- assign static IP or DHCP reservation
- update hostname
- regenerate SSH host keys (recommended)

---

## Notes
VM100 should never be used as a daily workload VM.

VM100 is treated as the “source image” for all standardized builds.

Any major changes require:

- new backup
- snapshot
- restore test verification

Secure Boot is intentionally disabled for repeatability and reduced failure points.

Serial console access is mandatory for recovery workflows.
