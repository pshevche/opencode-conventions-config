# OpenCode Conventions Config

Shared OpenCode configuration for use across multiple repositories.

## Included

- **Plugins**:
  - `superpowers` - Brainstorming and other AI-powered workflows

- **Skills**:
  - `gh-issue` - Hand off GitHub issues to OpenCode agents
  - `grill-me` - Interview the user about plans/designs until shared understanding

- **Instructions**:
  - Conventional Commits documentation

## Setup in Other Repos

### 1. Install direnv

```bash
brew install direnv
```

Add to your shell (`~/.zshrc`):

```bash
eval "$(direnv hook zsh)"
```

### 2. Add as git submodule

```bash
git submodule add -n --depth 1 https://github.com/pshevche/opencode-conventions-config.git .opencode-conventions
```

### 3. Create .envrc

Create `.envrc` in the project root:

```bash
export OPENCODE_CONFIG_DIR="$PWD/.opencode-conventions"
```

Then run:

```bash
direnv allow
```

### 4. Update repos as needed

```bash
git submodule update --init --recursive
```

## Development

To update skills:

```bash
# Fetch grill-me from mattpocock/skills
# Update .opencode/skills/grill-me/SKILL.md

# gh-issue skill is project-agnostic - update from here
```

## Notes

- Permissions and LSP config should be repo-specific
- The `OPENCODE_CONFIG_DIR` is loaded after local project config, so repo-specific settings take precedence
- Plugins are loaded from this config automatically when OPENCODE_CONFIG_DIR is set