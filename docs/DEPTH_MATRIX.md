# Depth matrix

Update this table when melting. Status words mean what they say:

| Status | Meaning |
|--------|---------|
| stub | Thin cue only. Usable as a reminder, not a playbook. |
| melted | Real Grok skill: when-to-use, steps, measurable checks, example, output shape. |

Never copy Claude plugin / agent / command totals into this inventory. Upstream [LibreEmbed-Claude-Code](https://github.com/HermeticOrmus/LibreEmbed-Claude-Code) is proof that the *job* exists, not a count this repo has earned.

| ID | Kind | Status | Source (Claude, for melt) | Notes |
|----|------|--------|---------------------------|-------|
| bare-metal-bringup | skill | melted | plugins/bare-metal | Clocks, reset, map, first observable. No invented clock trees. |
| rtos-task-design | skill | melted | plugins/rtos-patterns | Priorities, IPC, inversion, stack recipe. No invented Hz. |
| comm-bus-drivers | skill | stub | plugins/communication-buses | Init/timeout cue only. |
| firmware-ota | skill | melted | plugins/firmware-update | Dual-bank, confirm-after-self-test, power-loss. No keys. |
| memory-static-alloc | skill | stub | plugins/memory-management | Pool/heap cue only. |
| power-budget | skill | stub | plugins/power-management | Sleep/wake cue only. |
| iot-protocol-pick | skill | stub | plugins/iot-protocols | Constraint cue only. |
| embedded-test-hil | skill | stub | plugins/embedded-testing | Flash-safe loop cue only. |
| embed-orchestrator | agent | stub | suite agents | Coordinates the skills; not a melted specialist. |

This repo now: **3 melted skills**, **5 stub skills**, **1 stub agent**.

Where they live: melted skills in `plugins/libre-embed-grok/skills/<name>/SKILL.md` (the plugin installs them); stubs in `stubs/<name>/SKILL.md` (nothing installs them); the agent in `AGENTS/embed-orchestrator.md`.

Dogfood copies of every skill live at `.grok/skills/<name>/SKILL.md` and must match the canonical file above. CI checks it.

## Pack entries (installed, not melted)

The marketplace also lists every plugin of [LibreEmbed-Claude-Code](https://github.com/HermeticOrmus/LibreEmbed-Claude-Code) as a remote entry: **16 entries**, all pinned to one pack commit (the `sha` in `.grok-plugin/marketplace.json`). Grok reads those plugin folders as they are. They are not counted in the melted inventory above. `scripts/pin-pack.sh` re-pins them; CI fails when the pack gains or loses a plugin.

## Suite

Doctrine: [grok-build-reality-os](https://github.com/HermeticOrmus/grok-build-reality-os). Sibling Libre*-Grok-Build packs: [README suite footer](../README.md).
