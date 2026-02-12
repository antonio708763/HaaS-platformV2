# VM100 Golden Template (Debian 12 Baseline)

Purpose:  
This VM is the standardized Debian 12 base image used for all client-ready deployments.  
It is hardened, recoverable, and built to be cloned into role-specific production VMs (Docker host, DNS, monitoring, etc.).

This VM exists to validate:
- UEFI boot stability under Proxmox (OVMF)
- Serial console access for recovery
- SSH key authentication baseline
- Fail2Ban protection for SSH
- QEMU Guest Agent integration
- Backup + restore workflows

---

## Table of Contents

### Overview
- [VM Identity](#vm-identity)
- [Proxmox Configuration](#proxmox-configuration)
- [Storage Layout](#storage-layout)

### Baseline Software
- [Installed Packages](#installed-packages)
- [Services Enabled](#services-enabled)

### Security Baseline
- [SSH Hardening](#ssh-hardening)
- [Fail2Ban](#fail2ban)

### Operations & Reliability
- [Serial Console Configuration](#serial-console-configuration)
- [UEFI Boot Repair Notes](#uefi-boot-repair-notes)
- [Fix for Missing /run/sshd](#fix-for-missing-runsshd)
- [Backup + Restore Standard](#backup--restore-standard)

### Template Workflow
- [Snapshot Policy](#snapshot-policy)
- [Template Conversion](#template-conversion)
- [Clone Procedure](#clone-procedure)

---

## VM Identity

VMID: 100  
Name: debian12-base-restored  
OS: Debian GNU/Linux 12 (Bookworm)  
Role: Golden Template (baseline image)

---

## Proxmox Configuration

Firmware:
- BIOS: OVMF (UEFI)

Machine Type:
- q35

Boot Order:
- scsi0

EFI Disk:
- efidisk0 enabled
- Secure Boot disabled (pre-enrolled-keys=0)

This ensures predictable UEFI behavior and avoids Secure Boot shim issues.

---

## Storage Layout

Main OS Disk:
- scsi0 (ZFS-backed)

EFI Variables Disk:
- efidisk0 (ZFS-backed)

---

## Installed Packages

Required baseline packages:
- openssh-server
- qemu-guest-agent
- fail2ban
- sudo
- curl
- vim / nano (editor choice)

Optional but recommended:
- htop
- net-tools
- ca-certificates

---

## Services Enabled

Services expected running:
- ssh.service
- qemu-guest-agent.service
- fail2ban.service

Verify:
```bash
systemctl status ssh --no-pager
systemctl status qemu-guest-agent --no-pager
systemctl status fail2ban --no-pager
SSH Hardening
SSH goals:

SSH access must work immediately after clone

Key authentication is preferred

Password auth should be disabled for production workloads

Baseline validation:

sudo sshd -t
sudo systemctl restart ssh
sudo systemctl status ssh --no-pager
Fail2Ban
Fail2Ban protects SSH against brute-force login attempts.

Install and enable:

sudo apt update
sudo apt install -y fail2ban
sudo systemctl enable --now fail2ban
Verify jail status:

sudo fail2ban-client status
sudo fail2ban-client status sshd
Expected:

Jail list includes sshd

fail2ban service active and running

Serial Console Configuration
Serial console is required for recovery access when networking/SSH fails.

This allows use of:

qm terminal 100
Guest configuration:

Serial getty enabled on ttyS0

Verify inside VM:

systemctl status serial-getty@ttyS0.service --no-pager
UEFI Boot Repair Notes
UEFI boot issues were observed during VM recovery.

Fix actions performed:

Verified EFI loader exists:

/boot/efi/EFI/debian/shimx64.efi

/boot/efi/EFI/debian/grubx64.efi

Reinstalled bootloader packages:

sudo apt update
sudo apt install --reinstall grub-efi-amd64 shim-signed
sudo update-grub
Secure Boot keys disabled on Proxmox EFI disk

This resolved boot loops and “No bootable device” issues.

Fix for Missing /run/sshd
Issue encountered:

ssh.service failed with error:

Missing privilege separation directory: /run/sshd

Fix implemented permanently using tmpfiles rule.

Create file:

sudo tee /etc/tmpfiles.d/sshd.conf >/dev/null <<'EOF'
d /run/sshd 0755 root root -
EOF
Apply immediately:

sudo systemd-tmpfiles --create /etc/tmpfiles.d/sshd.conf
ls -ld /run/sshd
Verify:

sudo sshd -t
sudo systemctl restart ssh
sudo systemctl status ssh --no-pager
This ensures SSH survives reboot and cloning reliably.

Backup + Restore Standard
Backups are performed via Proxmox vzdump to dedicated backup storage.

Backup storage target:

backup-hdd mounted at /mnt/backup

Manual backup:

vzdump 100 --storage backup-hdd --compress zstd --mode snapshot
Nightly scheduled backup job:

Configured in Proxmox cluster backup job list

Retention: 7 backups

Snapshot Policy
Snapshots are used only for temporary rollback testing.

Snapshots must be deleted before converting to template.

List snapshots:

qm listsnapshot 100
Delete snapshot:

qm delsnapshot 100 <snapshot-name>
Template Conversion
VM100 must have:

No snapshots

Stable boot

SSH working

fail2ban working

qemu-guest-agent running

Convert to template:

qm template 100
Clone Procedure
Clone VM100 into a new VMID:

qm clone 100 200 --name docker-host-01 --full 1
After clone:

Assign static DHCP reservation or static IP

Update hostname

Regenerate SSH host keys (recommended for production clones)

Notes
VM100 is treated as the “golden baseline” and should not be used as a daily workload VM.

Any modifications to VM100 must be followed by:

backup

snapshot

restore verification

Secure Boot is intentionally disabled for stability and repeatability.

Serial console is mandatory for recovery workflows.
