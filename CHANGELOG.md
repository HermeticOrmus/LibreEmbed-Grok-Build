# Changelog

## [1.0.0] - 2026-09-30

The Grok edition: the melted skills install as a Grok plugin, and the same marketplace installs every LibreEmbed-Claude-Code plugin, pinned to one commit of the pack. The [kintsugi ledger](./LEDGER.md) records each v0 crack and its seal.

### Added

- `plugins/libre-embed-grok/`, the Grok-native plugin (`.grok-plugin/plugin.json`, version 1.0.0) with the three melted skills: `bare-metal-bringup`, `rtos-task-design`, `firmware-ota`.
- `.grok-plugin/marketplace.json` (`libre-embed-grok`): the Grok-native plugin plus all 16 LibreEmbed-Claude-Code plugins as remote entries pinned to pack commit `87880829cd3dbd5667c9e678b76b7024566666f8`.
- `scripts/pin-pack.sh`: re-pins the pack entries to the pack's `main`, adds new pack plugins, drops removed ones, and prints the diff; `--check` fails on an unreachable SHA or a changed plugin list.
- `.github/workflows/validate.yml`: `grok plugin validate`, the dogfood copy check, the doc install-line check, the pin check, and an install of every entry into a clean `GROK_HOME`.
- Issue forms for feedback, routing misses and plugin proposals, with the `feedback`, `routing-miss` and `plugin-proposal` labels.
- [LEDGER.md](./LEDGER.md), [stubs/README.md](./stubs/README.md), and "Ways to contribute" in [CONTRIBUTING.md](./CONTRIBUTING.md).

### Changed

- Install is `grok plugin marketplace add HermeticOrmus/LibreEmbed-Grok-Build` then `grok plugin install libre-embed-grok@libre-embed-grok --trust`. The folder copy still works from the new path, `plugins/libre-embed-grok/skills/*`.
- Melted skills moved from `skills/` to `plugins/libre-embed-grok/skills/`; the five stubs moved to `stubs/`. The `.grok/skills/` dogfood copy stays and matches both.
- The v0 bundle stub `.grok/plugins/libreembed-core/` moved to `stubs/libreembed-core/`, marked superseded.
- README gains the family header, the marketplace install and the real Depth table; QUICK_START, AGENTS.md, DEPTH_MATRIX and MELT_RULES follow the new paths.

### Fixed

- Stubs no longer install as if they were playbooks: their descriptions start "Stub, not a playbook." and name the pack plugin that holds the real depth.
- The v0 plugin folder installed as an unversioned plugin with no skills; the new plugin validates with its three skills.

### Upgrading from v0

- If you copied `skills/*` into a project or `~/.grok/skills/`, remove the five stub folders from that copy, or switch to the marketplace install so `grok plugin update` brings changes.
- Paths that pointed at `skills/<name>` now point at `plugins/libre-embed-grok/skills/<name>` (melted) or `stubs/<name>` (stubs).

## [0.1.0] — 2026-09-20

### Changed

- Melted `skills/bare-metal-bringup/SKILL.md`, `skills/rtos-task-design/SKILL.md`, and `skills/firmware-ota/SKILL.md` into usable Grok skills (when-to-use, steps, checks, examples, output shape). Dogfood copies under `.grok/skills/` match.
- Rewrote [QUICK_START.md](./QUICK_START.md) for a clean-machine install (<5 min) with paths that exist in this repo.
- Updated [docs/DEPTH_MATRIX.md](./docs/DEPTH_MATRIX.md): 3 melted, 5 stub skills, 1 stub agent. No Claude inventory counts.
- Suite footers on README, QUICK_START, and AGENTS.md now link Reality OS plus the sibling Libre*-Grok-Build packs.

## [0.0.1] — 2026-09-19

### Added

- Public scaffold for LibreEmbed-Grok-Build (v0 stubs).
- Stub SKILL.md for first skills + suite orchestrator agent.
- README, LICENSE (MIT), GOLD_HAT, QUICK_START, CONTRIBUTING, SECURITY.
- Depth matrix + melt rules docs.

### Notes

- Honest stubs — not fake upstream depth counts. Melt next.
