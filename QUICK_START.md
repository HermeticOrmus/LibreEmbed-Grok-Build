# Quick Start — LibreEmbed for Grok Build

> From a clean machine to one firmware review cue in under 5 minutes.

Doctrine first: put [grok-build-reality-os](https://github.com/HermeticOrmus/grok-build-reality-os) `AGENTS.md` on the machine (global Grok doctrine). This pack does not replace it.

## Prerequisites

- Grok Build (`grok --version` prints a version)
- `git` and `jq` for the clone paths and the install-everything loop
- A board/firmware repo you own or are authorized to flash, **or** this repo as the working tree

## Layout this file assumes

Verified against this repository (do not invent extra folders):

```text
plugins/libre-embed-grok/                     # the Grok-native plugin
plugins/libre-embed-grok/skills/<name>/SKILL.md  # melted skill bodies (copy these for the manual path)
stubs/<name>/SKILL.md                         # stub cues; not installed
AGENTS/embed-orchestrator.md
docs/DEPTH_MATRIX.md
docs/MELT_RULES.md
.grok-plugin/marketplace.json                 # the plugin + every pack plugin, pinned
.grok/skills/<name>/SKILL.md                  # dogfood copy of the plugin skills and stubs
stubs/libreembed-core/                        # v0 plugin bundle stub, kept as the record
```

Melted (usable now): `bare-metal-bringup`, `rtos-task-design`, `firmware-ota`, in `plugins/libre-embed-grok/skills/`.
Still stubs: the other five skills + the orchestrator. Honest table: [docs/DEPTH_MATRIX.md](./docs/DEPTH_MATRIX.md).

## Install (pick one)

### A. Marketplace (recommended)

```bash
grok plugin marketplace add HermeticOrmus/LibreEmbed-Grok-Build
grok plugin install libre-embed-grok@libre-embed-grok
grok plugin details libre-embed-grok
```

The same marketplace lists every [LibreEmbed-Claude-Code](https://github.com/HermeticOrmus/LibreEmbed-Claude-Code) plugin, pinned to one commit of the pack. Install the ones your board needs by name:

```bash
grok plugin install rtos-patterns@libre-embed-grok
grok plugin install communication-buses@libre-embed-grok
```

Or install every entry:

```bash
for p in $(grok plugin list --json --available | jq -r '.[] | select(.marketplace == "libre-embed-grok" and .status == "available") | .name'); do
  grok plugin install "$p@libre-embed-grok"
done
```

`libre-embed-hooks` is format-compatible with Grok, but its behavior inside a Grok session is not verified yet (see [LEDGER.md](./LEDGER.md)). Skip it if you only want skills and agents.

To pick up a new pin later: `grok plugin marketplace update`, then `grok plugin update`.

### B. Dogfood this repo

```bash
git clone https://github.com/HermeticOrmus/LibreEmbed-Grok-Build.git
cd LibreEmbed-Grok-Build
# A copy of the skills and stubs is already at .grok/skills/. Open this folder in Grok Build.
```

### C. Copy into your firmware project

The v0 path, for a project that should carry the skill files itself.

```bash
git clone https://github.com/HermeticOrmus/LibreEmbed-Grok-Build.git ~/LibreEmbed-Grok-Build
cd /path/to/your-firmware-project
mkdir -p .grok/skills
cp -R ~/LibreEmbed-Grok-Build/plugins/libre-embed-grok/skills/* .grok/skills/
```

Confirm the copy landed:

```bash
test -f .grok/skills/bare-metal-bringup/SKILL.md
test -f .grok/skills/rtos-task-design/SKILL.md
test -f .grok/skills/firmware-ota/SKILL.md
ls .grok/skills
```

You should see three skill directories, matching `plugins/libre-embed-grok/skills/` in this repo. The stubs are not copied: they are pointers to pack plugins, not skills.

### D. User-global copy

```bash
git clone https://github.com/HermeticOrmus/LibreEmbed-Grok-Build.git ~/LibreEmbed-Grok-Build
mkdir -p ~/.grok/skills
cp -R ~/LibreEmbed-Grok-Build/plugins/libre-embed-grok/skills/* ~/.grok/skills/
```

Same three `test -f` checks as C, under `~/.grok/skills/`.

### Upgrading from v0

If you copied `skills/*` into a project or `~/.grok/skills/`, that copy holds all eight folders, stubs included. Remove the five stub folders (`comm-bus-drivers`, `memory-static-alloc`, `power-budget`, `iot-protocol-pick`, `embedded-test-hil`) from the copy, or replace the copy with path A so updates arrive through `grok plugin update`.

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

- [ ] `grok plugin list` shows `libre-embed-grok` (path A), or the three skill files exist at the copy path you chose (C or D)
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
