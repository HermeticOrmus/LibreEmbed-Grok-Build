# libre-embed-grok

The Grok-native LibreEmbed plugin. It carries the skills melted for Grok Build, and only those:

| Skill | Job | Melted from (pack plugin) |
|-------|-----|---------------------------|
| `bare-metal-bringup` | Clocks, reset, linker, first blink or UART byte | `bare-metal` |
| `rtos-task-design` | Priorities, IPC, stacks, inversion guards | `rtos-patterns` |
| `firmware-ota` | Dual-bank, confirm after self-test, rollback | `firmware-update` |

Install:

```bash
grok plugin marketplace add HermeticOrmus/LibreEmbed-Grok-Build
grok plugin install libre-embed-grok@libre-embed-grok --trust
```

The five stub skills are not in this plugin. They live in [stubs/](../../stubs/), and each names the pack plugin that holds the real depth. The same marketplace installs those pack plugins.

Manifest: [.grok-plugin/plugin.json](./.grok-plugin/plugin.json). Honest inventory: [docs/DEPTH_MATRIX.md](../../docs/DEPTH_MATRIX.md). The v0 bundle stub this plugin replaces is kept at [stubs/libreembed-core/](../../stubs/libreembed-core/).
