# Backup and Restore Standard (Client Track)

## Goals

- nightly automated backups
- clear retention policy
- proven restore procedure (restore drills)

---

## Backup Storage

Backups are stored on a dedicated backup disk mounted to the Proxmox host (example: `/mnt/backup`)
and exposed to Proxmox as a `dir` storage.

Example:

- mount point: `/mnt/backup`
- Proxmox storage name: `backup-hdd`

---

## Manual Backup (Single VM)

Example:

- VMID: `100`
- Storage: `backup-hdd`
- Compression: `zstd`
- Mode: `snapshot`

Command:

~~~bash
vzdump 100 --storage backup-hdd --compress zstd --mode snapshot
~~~

---

## Nightly Scheduled Backups

Create a scheduled job via the Proxmox API:

~~~bash
pvesh create /cluster/backup \
  --id nightly-vm100 \
  --storage backup-hdd \
  --mode snapshot \
  --compress zstd \
  --dow mon,tue,wed,thu,fri,sat,sun \
  --starttime 02:00 \
  --vmid 100 \
  --maxfiles 7
~~~

Retention policy:

- keep the last **7** backups

---

## Restore Verification (Required)

At least once after major baseline changes:

1. Restore the latest backup to a test VMID (example: `101`)
2. Confirm boot success and login prompt
3. Confirm network connectivity comes up
4. Delete the test VM after validation

---

## Minimum Standard

A deployment is not considered client-ready unless:

- backups are enabled
- retention is configured
- restore drill has been performed and documented
