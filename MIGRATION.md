# Migration Map (HaaS-platform → HaaS-platformV2)

This file tracks every markdown document from the legacy repo and what happens to it in V2.

---

## Legend

- **Port** = bring into V2 and polish
- **Merge** = combine with other doc(s) into one
- **Archive** = keep in V2 under `archive/` (legacy, reference, troubleshooting)
- **Rebuild** = rewrite clean from scratch, preserving key info

---

## Status

- **Todo**
- **In Progress**
- **Done**

---

## Migration Table

| Old Path (V1) | Action | New Path (V2) | Notes | Status |
|---|---|---|---|---|
| README.md | Rebuild | README.md | Rewrite to match V2 structure | Done |
| philosophy.md | Port | docs/philosophy.md | Preserve principles; light polish | Done |
| automation-ideas.md | Port | docs/automation-ideas.md | Keep ideas; organize sections | Done |
| docs/glossary.md | Port | docs/glossary.md | Keep terminology consistent | Done |
| docs/decision-log.md | Port | docs/decision-log.md | Preserve history + reasoning | Done |
| vm/debian12-base.md | Port | addons-research/vm-debian12-base.md | Research track VM spec (GPU passthrough / VAAPI) | Done |
| hardware/lab-build.md | Port | addons-research/lab-build.md | Research track hardware spec | Done |
| host/proxmox-setup.md | Port | host/proxmox-setup.md | Core build/runbook | Done |
| host/network-design.md | Port | host/network-design.md | Core design + standards | Done |
| stacks/immich/README.md | Port | stacks/immich/README.md | Stack install/runbook | Done |
| stacks/immich/troubleshooting.md | Archive | archive/stacks/immich/troubleshooting.md | Keep as reference, not standard flow | Done |
