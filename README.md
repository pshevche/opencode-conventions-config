# OpenCode Conventions Config

Shared OpenCode configuration for use across multiple repositories.

## What's included

### Plugin

- **superpowers** (`obra/superpowers`) — Injects brainstorming workflows and
  registers the superpowers skill library into every session.

### Agents

| Agent | Invoke as | Model | Role |
|---|---|---|---|
| Architect | `@plan` | Claude Sonnet 4.6 | Planning, task breakdown, delegation, final review |
| Implementer | `@build` | Kimi K2.6 | Writing and editing code |
| QA | `@qa` | Kimi K2.5 | Writing tests, analysing failures |
| Reviewer | `@reviewer` | MiniMax M2.5 Free | Code review, PR descriptions |
| Fast loop | `@fast-loop` | Nemotron 3 Super Free | Renames, formatting, repetitive edits |

Agent prompts live in `.opencode/prompts/`.

The Architect (`@plan`) runs the **grill-me** interview protocol before
producing any plan — asking one question at a time with a recommended answer
until requirements are fully understood.

### Skills

- **grill-me** — Interview the user relentlessly about a plan until reaching
  shared understanding. Loaded automatically by `@plan`; also available
  on-demand.
- **gh-issue** — Hand off GitHub issues to OpenCode agents.

### Instructions

- **Conventional Commits** — Commit message format and type reference,
  applied to every session.

### Global permissions

- All operations default to `ask`.
- `read` and safe `git` inspection commands (`status`, `log`, `diff`, `show`)
  are pre-approved.
- Agent-level overrides tighten or loosen per role (e.g. `plan` cannot
  write or edit files; `build` has full write access).

---

## Setup in other repos

### 1. Install direnv

```bash
brew install direnv
```

Add to your shell (`~/.zshrc`):

```bash
eval "$(direnv hook zsh)"
```

### 2. Add as a git submodule

```bash
git submodule add -n --depth 1 https://github.com/pshevche/opencode-conventions-config.git .opencode-conventions
```

### 3. Create `.envrc`

```bash
export OPENCODE_CONFIG_DIR="$PWD/.opencode-conventions"
```

Then allow it:

```bash
direnv allow
```

### 4. Keep up to date

```bash
git submodule update --init --recursive
```

---

## Notes

- Permissions and LSP config should remain repo-specific.
- `OPENCODE_CONFIG_DIR` is loaded after local project config, so repo-specific
  settings take precedence.
- Free-tier agents (`@reviewer`, `@fast-loop`) should not receive proprietary
  business logic or internal API keys — use `@build` or `@qa` instead.
- Build/test commands default to Gradle; update them per project in your local config.
