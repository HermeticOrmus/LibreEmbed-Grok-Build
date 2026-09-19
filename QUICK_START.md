# Quick Start — LibreEmbed for Grok Build

> From zero to a firmware review cue in under 5 minutes.

## Prerequisites

- Grok Build installed and working
- A board/firmware repo you own or are authorized to work on

## Install skills (repo-local)

```bash
git clone https://github.com/HermeticOrmus/LibreEmbed-Grok-Build.git
cd your-project
mkdir -p .grok/skills
cp -R /path/to/LibreEmbed-Grok-Build/skills/* .grok/skills/
```

Or user-global:

```bash
mkdir -p ~/.grok/skills
cp -R /path/to/LibreEmbed-Grok-Build/skills/* ~/.grok/skills/
```

## First-run teach cue

1. **Bring-up** — "Run bare-metal-bringup: clocks, reset, first blink, linker map."
2. **RTOS** — "Run rtos-task-design for task priorities and IPC without priority inversion."
3. **OTA** — "Run firmware-ota for dual-bank / rollback checklist."

## Hard rules

- Never embed secrets in prompts or examples.
- Honest stubs — melt depth next.
- Gold Hat: empower or extract?

## Smoke checklist

- [ ] Skills visible to Grok
- [ ] One skill run produces measurable output
- [ ] No secrets in output
