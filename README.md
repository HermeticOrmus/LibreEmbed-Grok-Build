# LibreEmbed-Grok-Build

**Embedded / firmware / IoT skills for Grok Build** — ported and melted from [LibreEmbed-Claude-Code](https://github.com/HermeticOrmus/LibreEmbed-Claude-Code), not a dumb copy.

> Status: **v0 public scaffold** — honest stubs. Melt depth next.

## Why this exists

Most LLM coding patterns assume a web stack. Embedded needs bring-up, RTOS, buses, OTA, and on-target test cues — melted for Grok Build from LibreEmbed-Claude-Code.

## Install (<5 min)

See [QUICK_START.md](./QUICK_START.md).

```bash
mkdir -p .grok/skills
cp -R skills/* .grok/skills/
```

Doctrine: install [grok-build-reality-os](https://github.com/HermeticOrmus/grok-build-reality-os) `AGENTS.md` on the machine first.

## Depth matrix (honest)

| Artifact | v0 scaffold | Upstream Claude (proof) |
|----------|-------------|-------------------------|
| Skills (melted bodies) | 8 stubs → fill next | see upstream suite |
| Agents | 1 (`embed-orchestrator`) | upstream agents |

Counts on the right are **upstream proof**, not this repo's claim until melted.

## First skills

| Skill | Job |
|-------|-----|
| bare-metal-bringup | Bare-metal bring-up checklist: clocks, reset, linker, first blink |
| rtos-task-design | RTOS task design: priorities, IPC, stack sizing, priority inversion guards |
| comm-bus-drivers | I2C/SPI/UART/CAN driver review — init, timeouts, error paths |
| firmware-ota | OTA / dual-bank / rollback hygiene for field updates |
| memory-static-alloc | Static allocation, pools, stack/heap analysis for constrained MCUs |
| power-budget | Sleep modes, wake sources, and energy budget for battery devices |
| iot-protocol-pick | Pick MQTT/CoAP/BLE/LoRaWAN/etc |
| embedded-test-hil | On-target / HIL test outline — mocks, fixtures, flash-safe loops |

Agent: `AGENTS/embed-orchestrator.md` — full suite pass.

## Layout (Grok Build)

```
skills/                 # install into .grok/skills or ~/.grok/skills
AGENTS/                 # suite agents
.grok/plugins/          # optional plugin bundle
docs/                   # DEPTH_MATRIX, MELT_RULES
```

## Gold Hat

[GOLD_HAT.md](./GOLD_HAT.md) — empower or extract?

## Suite

- Doctrine: [grok-build-reality-os](https://github.com/HermeticOrmus/grok-build-reality-os)
- Sibling: [LibreUIUX-Grok-Build](https://github.com/HermeticOrmus/LibreUIUX-Grok-Build) · [LibreSessionFlow-Grok-Build](https://github.com/HermeticOrmus/LibreSessionFlow-Grok-Build) · [LibreGEO-Grok-Build](https://github.com/HermeticOrmus/LibreGEO-Grok-Build)
- Skills packs: [grok-skills](https://github.com/HermeticOrmus/grok-skills) · [grok-build-skills](https://github.com/HermeticOrmus/grok-build-skills)
- Claude proof: [LibreEmbed-Claude-Code](https://github.com/HermeticOrmus/LibreEmbed-Claude-Code)
- https://ormus.solutions

## License

MIT — see [LICENSE](./LICENSE).
