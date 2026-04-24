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

### Prerequisites

- [jq](https://jqlang.github.io/jq/download/) must be installed.

```bash
brew install jq   # macOS
```

### 1. Clone this repo somewhere temporary

```bash
git clone --depth 1 https://github.com/pshevche/opencode-conventions-config.git /tmp/opencode-conventions-config
```

### 2. Run the installer

From the root of your target repository:

```bash
/tmp/opencode-conventions-config/install.sh
```

Or pass the target directory explicitly:

```bash
/tmp/opencode-conventions-config/install.sh /path/to/your/repo
```

The script will:

1. Copy `.opencode/instructions/`, `.opencode/prompts/`, and `.opencode/skills/`
   into your repo, creating any missing directories.
2. Merge `opencode.json` into your repo's `opencode.json`:
   - **Your values win** on scalar fields (`model`, `small_model`, …).
   - **Arrays** (`plugin`, `instructions`) are unioned — no duplicates.
   - **`agent` map** — your agent entries win; missing agents are added from
     the conventions config.
   - **`permission` map** — your entries win; missing keys are filled in.

### 3. Review and commit

```bash
git diff
git add opencode.json .opencode/
git commit -m "chore: add opencode conventions config"
```

### Keeping up to date

Re-run the installer whenever you want to pull in the latest conventions:

```bash
git clone --depth 1 https://github.com/pshevche/opencode-conventions-config.git /tmp/opencode-conventions-config
/tmp/opencode-conventions-config/install.sh
```

---

## Notes

- Permissions and LSP config should remain repo-specific — the installer will
  not overwrite keys you already have in `opencode.json`.
- Agent prompts are copied verbatim; edit them in your repo after installation
  if you need project-specific tweaks.
