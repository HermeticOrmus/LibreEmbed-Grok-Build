# Stubs

A stub is a thin cue: a name, a one-line job, and five steps. It is a reminder, not a playbook, so nothing here installs. Each stub names the pack plugin that holds the real depth, and that plugin installs from this repo's marketplace.

| Stub | Job | Real depth (pack plugin) | Install |
|------|-----|--------------------------|---------|
| [comm-bus-drivers](./comm-bus-drivers/SKILL.md) | I2C/SPI/UART/CAN review cue | [`communication-buses`](https://github.com/HermeticOrmus/LibreEmbed-Claude-Code/tree/main/plugins/communication-buses) | `grok plugin install communication-buses@libre-embed-grok` |
| [memory-static-alloc](./memory-static-alloc/SKILL.md) | Static pools, stack and heap cue | [`memory-management`](https://github.com/HermeticOrmus/LibreEmbed-Claude-Code/tree/main/plugins/memory-management) | `grok plugin install memory-management@libre-embed-grok` |
| [power-budget](./power-budget/SKILL.md) | Sleep, wake, energy cue | [`power-management`](https://github.com/HermeticOrmus/LibreEmbed-Claude-Code/tree/main/plugins/power-management) | `grok plugin install power-management@libre-embed-grok` |
| [iot-protocol-pick](./iot-protocol-pick/SKILL.md) | MQTT/CoAP/BLE/LoRaWAN pick cue | [`iot-protocols`](https://github.com/HermeticOrmus/LibreEmbed-Claude-Code/tree/main/plugins/iot-protocols) | `grok plugin install iot-protocols@libre-embed-grok` |
| [embedded-test-hil](./embedded-test-hil/SKILL.md) | On-target and HIL cue | [`embedded-testing`](https://github.com/HermeticOrmus/LibreEmbed-Claude-Code/tree/main/plugins/embedded-testing) | `grok plugin install embedded-testing@libre-embed-grok` |

Also here: [libreembed-core/](./libreembed-core/), the v0 plugin bundle stub. It had no manifest and installed only a copy of the stub orchestrator. It is kept as the record; [plugins/libre-embed-grok](../plugins/libre-embed-grok/) replaces it.

The suite agent [AGENTS/embed-orchestrator.md](../AGENTS/embed-orchestrator.md) is also a stub coordinator. It stays where [AGENTS.md](../AGENTS.md) points, and nothing installs it: you merge it by hand.

## Melt a stub

1. Write the skill to the melted bar in [docs/MELT_RULES.md](../docs/MELT_RULES.md): when to use, steps, measurable checks, a worked example, an output shape.
2. `git mv stubs/<name> plugins/libre-embed-grok/skills/<name>`, drop the stub line, and give the frontmatter a routing description (`Use when ...`).
3. Copy it to `.grok/skills/<name>/SKILL.md` (CI checks the copy matches).
4. Update [docs/DEPTH_MATRIX.md](../docs/DEPTH_MATRIX.md), this table, and the README skills table.

The dogfood copies of these stubs in `.grok/skills/` match the files here, so a session opened in this repo sees them described as stubs.
