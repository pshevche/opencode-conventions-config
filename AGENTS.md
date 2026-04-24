# Project Rules

This file is read by all agents at the start of every session.
Keep it accurate and concise — every line costs tokens.

---

## Agent team

| Agent | Model | Invoke for |
|---|---|---|
| `@plan` (Architect) | Claude Sonnet 4.6 | Planning, task breakdown, delegation, final review |
| `@build` (Implementer) | Kimi K2.6 | Writing and editing code |
| `@qa` | Kimi K2.5 | Writing tests, analysing failures |
| `@reviewer` | MiniMax M2.5 Free | Code review, PR descriptions |
| `@fast-loop` | Nemotron 3 Super Free | Renames, formatting, repetitive edits |
| `@explore` (built-in) | — | Read-only codebase exploration |

---

## Build and test commands

<!-- TODO: update for your project -->
- Build: `./gradlew build`
- Test (all): `./gradlew test`
- Test (single module): `./gradlew :module-name:test`
- Lint: `./gradlew check`
- Format: `./gradlew spotlessApply`

---

## Repository structure

<!-- TODO: describe your project layout -->
```
src/
  main/       — production code
  test/       — unit and integration tests
build.gradle  — build configuration
AGENTS.md     — this file
opencode.json — OpenCode agent config
```

---

## Code conventions

<!-- TODO: update for your project -->
- Language: Java / Kotlin
- Style guide: follow the patterns in the surrounding code
- Test framework: JUnit 5
- No new dependencies without explicit approval

---

## Cost and context rules (all agents)

- Summarise completed work before starting new tasks to keep context compact.
- Use @explore for targeted file reads. Do not load entire directories.
- Architect (@plan): stay under 200K tokens — cost doubles above that threshold.
- Free-tier agents (@reviewer, @fast-loop): do not send proprietary business
  logic or internal API keys. Use @build or @qa instead.
