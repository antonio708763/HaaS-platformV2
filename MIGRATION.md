
# Migration Map (HaaS-platform → HaaS-platformV2)

This file tracks every markdown document from the legacy repo and what happens to it in V2.

## Legend
- Port = bring into V2 and polish
- Merge = combine with other doc(s) into one
- Archive = keep in V2 under archive/ (legacy, reference, troubleshooting)
- Rebuild = rewrite clean from scratch, preserving key info

## Status
- Todo / In Progress / Done

---

| Old Path (V1) | Action | New Path (V2) | Notes | Status |
|---|---|---|---|---|
📌 Migration Map (First Draft)
Root Docs
Old Repo (V1)	Action	New Repo (V2)	Why
README.md	Rebuild	README.md	V2 should be cleaner and reflect new structure
philosophy.md	Port	docs/philosophy.md	Important long-term reference
automation-ideas.md	Port	docs/automation-ideas.md	Valuable planning doc
Docs Folder
Old Repo (V1)	Action	New Repo (V2)	Why
docs/glossary.md	Port	docs/glossary.md	Must keep for standard terminology
docs/decision-log.md	Port	docs/decision-log.md	Critical history + reasoning
VM Folder
Old Repo (V1)	Action	New Repo (V2)	Why
vm/debian12-base.md	Merge	vm/100-golden.md	Debian base template is basically VM100 golden

(We keep the original details but merge into your new VM100 doc so there’s one source of truth.)

Hardware Folder
Old Repo (V1)	Action	New Repo (V2)	Why
hardware/lab-build.md	Port	addons-research/lab-build.md	Research hardware belongs in research track
Host Folder
Old Repo (V1)	Action	New Repo (V2)	Why
host/proxmox-setup.md	Port	host/proxmox-setup.md	Core standard
host/network-design.md	Port	host/network-design.md	Core standard
Stacks Folder
Old Repo (V1)	Action	New Repo (V2)	Why
stacks/immich/README.md	Port	stacks/immich/README.md	Client-ready service stack doc
stacks/immich/troubleshooting.md	Archive	archive/stacks/immich/troubleshooting.md	Useful, but not part of clean “standard install flow”
