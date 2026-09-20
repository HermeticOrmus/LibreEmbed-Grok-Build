# Contributing

## Melt, don't clone

Ports from LibreEmbed-Claude-Code must follow Liquid Gold:

1. Keep model-agnostic Embed knowledge.
2. Strip Claude-only paths, `model:` pins, Anthropic install residue.
3. Ship as Grok `SKILL.md` / agents under `.grok/` conventions.
4. Teach while helping (Gold Hat).

## Skill format

```
skills/<name>/SKILL.md
```

YAML frontmatter: `name`, `description`. Body: when to use, steps, measurable checks, worked example, output shape.

## PR bar

- Honest depth: only count what you melt. Status is `stub` or `melted` in [docs/DEPTH_MATRIX.md](./docs/DEPTH_MATRIX.md).
- No "Grok killer" language. No Claude plugin/agent/command totals as this repo's inventory.
- Suite footer on README / QUICK_START / AGENTS.md: Reality OS + sibling Libre*-Grok-Build packs.
- Canonical skill body is `skills/<name>/SKILL.md`. Keep `.grok/skills/<name>/SKILL.md` identical.
- No secrets in skills, templates, or examples. No invented clock trees or sample rates.
