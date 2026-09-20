# Quick Start — LibreEmbed for Grok Build

> From a clean machine to one firmware review cue in under 5 minutes.

Doctrine first: put [grok-build-reality-os](https://github.com/HermeticOrmus/grok-build-reality-os) `AGENTS.md` on the machine (global Grok doctrine). This pack does not replace it.

## Prerequisites

- `git`
- Grok Build installed and able to see skills under `.grok/skills/` or `~/.grok/skills/`
- A board/firmware repo you own or are authorized to flash, **or** this repo as the working tree

## Layout this file assumes

Verified against this repository (do not invent extra folders):

```
skills/<name>/SKILL.md          # canonical skill bodies (copy these)
AGENTS/embed-orchestrator.md
docs/DEPTH_MATRIX.md
docs/MELT_RULES.md
.grok/skills/<name>/SKILL.md    # dogfood copy; must match skills/
.grok/plugins/libreembed-core/  # plugin stub; not required for first run
```

Melted (usable now): `skills/bare-metal-bringup/SKILL.md`, `skills/rtos-task-design/SKILL.md`, `skills/firmware-ota/SKILL.md`.
Still stubs: the other five skills + the orchestrator. Honest table: [docs/DEPTH_MATRIX.md](./docs/DEPTH_MATRIX.md).

## Install (pick one)

### A. Dogfood this repo (fastest)

```bash
git clone https://github.com/HermeticOrmus/LibreEmbed-Grok-Build.git
cd LibreEmbed-Grok-Build
# Skills are already at .grok/skills/ — open this folder in Grok Build.
```

### B. Install into your firmware project

```bash
git clone https://github.com/HermeticOrmus/LibreEmbed-Grok-Build.git ~/LibreEmbed-Grok-Build
cd /path/to/your-firmware-project
mkdir -p .grok/skills
cp -R ~/LibreEmbed-Grok-Build/skills/* .grok/skills/
```

Confirm the copy landed:

```bash
test -f .grok/skills/bare-metal-bringup/SKILL.md
test -f .grok/skills/rtos-task-design/SKILL.md
test -f .grok/skills/firmware-ota/SKILL.md
ls .grok/skills
```

You should see eight skill directories, matching `skills/` in this repo.

### C. User-global

```bash
git clone https://github.com/HermeticOrmus/LibreEmbed-Grok-Build.git ~/LibreEmbed-Grok-Build
mkdir -p ~/.grok/skills
cp -R ~/LibreEmbed-Grok-Build/skills/* ~/.grok/skills/
```

Same three `test -f` checks as B, under `~/.grok/skills/`.

### Optional suite agent (merge, do not replace)

```bash
# From your firmware project — merge into existing AGENTS.md / .grok/AGENTS.md.
# Do not overwrite Reality OS doctrine.
cat ~/LibreEmbed-Grok-Build/AGENTS/embed-orchestrator.md
```

Copy `AGENTS/embed-orchestrator.md` only when you want a multi-skill firmware pass. It is still a stub coordinator.

## First-run teach cue

In Grok Build, on firmware you own (do not flash hardware you are not authorized to touch):

1. **Bring-up** — "Run bare-metal-bringup: name the first observable, then clocks, reset path, linker map."
2. **RTOS** — "Run rtos-task-design. I will give rates and a latency budget. Do not invent Hz."
3. **OTA** — "Run firmware-ota for dual-bank / confirm-after-self-test / power-loss. No keys in the output."

You used melted LibreEmbed depth on Grok — not a Claude paste, not a fake plugin count.

## Hard rules

- Never embed secrets in prompts, examples, or output.
- Flash only boards you own or are authorized to write.
- Honest stubs — do not treat unmelted skills as playbooks.
- Gold Hat: empower or extract?

## Smoke checklist

- [ ] `bare-metal-bringup`, `rtos-task-design`, and `firmware-ota` files exist at the install path you chose
- [ ] Grok can see those three skills
- [ ] One bring-up pass named a first observable and used the map / clock checks (or marked unverified)
- [ ] One RTOS or OTA pass returned severity-ranked findings and remediations (no invented Hz, no keys)
- [ ] No secrets in prompts, examples, or output

## Suite

- Doctrine: [grok-build-reality-os](https://github.com/HermeticOrmus/grok-build-reality-os)
- This pack: [LibreEmbed-Grok-Build](https://github.com/HermeticOrmus/LibreEmbed-Grok-Build)
- Sibling Libre*-Grok-Build packs: [Arch](https://github.com/HermeticOrmus/LibreArch-Grok-Build) · [Copy](https://github.com/HermeticOrmus/LibreCopy-Grok-Build) · [DevOps](https://github.com/HermeticOrmus/LibreDevOps-Grok-Build) · [Embed](https://github.com/HermeticOrmus/LibreEmbed-Grok-Build) · [FinTech](https://github.com/HermeticOrmus/LibreFinTech-Grok-Build) · [GameDev](https://github.com/HermeticOrmus/LibreGameDev-Grok-Build) · [GEO](https://github.com/HermeticOrmus/LibreGEO-Grok-Build) · [MLOps](https://github.com/HermeticOrmus/LibreMLOps-Grok-Build) · [MobileDev](https://github.com/HermeticOrmus/LibreMobileDev-Grok-Build) · [SecOps](https://github.com/HermeticOrmus/LibreSecOps-Grok-Build) · [SessionFlow](https://github.com/HermeticOrmus/LibreSessionFlow-Grok-Build) · [WhatsApp](https://github.com/HermeticOrmus/LibreWhatsApp-Grok-Build)
- Skills collections: [grok-skills](https://github.com/HermeticOrmus/grok-skills) · [grok-build-skills](https://github.com/HermeticOrmus/grok-build-skills)
- Claude proof (upstream, not this inventory): [LibreEmbed-Claude-Code](https://github.com/HermeticOrmus/LibreEmbed-Claude-Code)
- https://ormus.solutions
