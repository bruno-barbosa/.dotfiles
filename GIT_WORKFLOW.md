# Enhanced Git Workflow

This document describes the enhanced git workflow features available in this dotfiles configuration.

## Table of Contents

1. [Git Aliases](#git-aliases)
2. [Git Functions](#git-functions)
3. [Conventional Commits](#conventional-commits)
4. [Commit Message Template](#commit-message-template)
5. [Git Hooks](#git-hooks)
6. [Tips and Tricks](#tips-and-tricks)

---

## Git Aliases

All git aliases are defined in `.zsh/aliases/.git.alias.zsh`.

### Basic Operations

| Alias | Command | Description |
|-------|---------|-------------|
| `g` | `git` | Short git |
| `gs` | `git status -sb` | Short status with branch info |
| `ga` | `git add` | Add files |
| `gaa` | `git add --all` | Add all files |
| `gap` | `git add --patch` | Interactive staging |

### Commits

| Alias | Command | Description |
|-------|---------|-------------|
| `gc` | `git commit -v` | Verbose commit (shows diff) |
| `gcm` | `git commit -m` | Commit with message |
| `gca` | `git commit -v --amend` | Amend last commit |
| `gcan` | `git commit -v --amend --no-edit` | Amend without editing message |

### Branches

| Alias | Command | Description |
|-------|---------|-------------|
| `gb` | `git branch` | List branches |
| `gba` | `git branch -a` | List all branches |
| `gbd` | `git branch -d` | Delete branch (safe) |
| `gbD` | `git branch -D` | Delete branch (force) |
| `gco` | `git checkout` | Checkout branch |
| `gcob` | `git checkout -b` | Create and checkout branch |
| `gcom` | `git checkout main/master` | Checkout main branch |
| `gbh` | Branch history | Pretty branch list with dates |

### Fetch, Pull, Push

| Alias | Command | Description |
|-------|---------|-------------|
| `gf` | `git fetch` | Fetch from remote |
| `gfa` | `git fetch --all --prune` | Fetch all and prune |
| `gl` | `git pull` | Pull from remote |
| `gpr` | `git pull --rebase` | Pull with rebase |
| `gp` | `git push` | Push to remote |
| `gpf` | `git push --force-with-lease` | Safer force push |
| `gpsup` | Set upstream and push | Push and set tracking |

### Logs

| Alias | Command | Description |
|-------|---------|-------------|
| `glog` | `git log --oneline --graph` | Simple log graph |
| `gloga` | `git log --oneline --graph --all` | All branches log |
| `glogp` | Pretty log | Formatted log with dates |
| `glogs` | `git log --stat` | Log with file stats |

### Stash

| Alias | Command | Description |
|-------|---------|-------------|
| `gsta` | `git stash` | Stash changes |
| `gstaa` | `git stash apply` | Apply stash |
| `gstl` | `git stash list` | List stashes |
| `gstp` | `git stash pop` | Pop stash |

### Other Useful Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `gd` | `git diff` | Show differences |
| `gdc` | `git diff --cached` | Show staged differences |
| `grh` | `git reset` | Reset changes |
| `grhh` | `git reset --hard` | Hard reset |
| `gbl` | `git blame -w` | Blame ignoring whitespace |
| `git-aliases` | Show all git aliases | List all g* aliases |

---

## Git Functions and Subcommands

Git functions are defined in `.zsh/functions/.git.func.zsh`, while git subcommands are executable scripts in `.config/git/subcommands/`.

Git subcommands can be called two ways:
- As a git command: `git cleanup-merged`
- Directly: `git-cleanup-merged`

### Branch Management

#### `gcb <branch-name>`
Create and switch to a new branch.

```bash
gcb feature/new-login
```

#### `git-cleanup-merged`
Delete all local branches that have been merged into main/master.

```bash
git-cleanup-merged
```

#### `git-cleanup-all`
Delete ALL local branches except main/master and develop (with confirmation).

```bash
git-cleanup-all
```

#### `git-cleanup-gone`
Delete local branches that track deleted remote branches.

```bash
# First, see which branches are gone
git-prune-remote

# Then delete them
git-cleanup-gone
```

#### `git-prune-remote`
Fetch and prune remote branches, showing which local branches track deleted remotes.

```bash
git-prune-remote
```

### Commit Information

#### `git-unpushed`
Show commits not yet pushed to remote.

```bash
git-unpushed
```

#### `git-unpulled`
Show commits in remote not yet pulled.

```bash
git-unpulled
```

### Repository Management

#### `git-init-repo <repo-name>`
Create a new repository with README and .gitignore.

```bash
git-init-repo my-new-project
# Creates directory, initializes git, adds README and .gitignore
```

#### `git-multi-status [directory]`
Check status of multiple git repositories.

```bash
git-multi-status ~/projects
# Shows uncommitted changes, unpushed/unpulled commits for all repos
```

### Utilities

#### `git-size`
Show repository size and object count.

```bash
git-size
```

#### `git-large-files`
Find the 20 largest files in git history.

```bash
git-large-files
```

#### `git-search <term>`
Search for commits by message.

```bash
git-search "fix bug"
```

#### `git-undo`
Undo last commit but keep changes staged.

```bash
git-undo
```

#### `git-amend`
Add all current changes to the last commit.

```bash
git-amend
```

#### `git-archive-branch`
Archive current branch to a tar.gz file.

```bash
git-archive-branch
# Creates: branch-name-20250101.tar.gz
```

---

## Conventional Commits

Conventional commits provide a standardized format for commit messages.

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, etc.)
- **refactor**: Code refactoring
- **perf**: Performance improvements
- **test**: Adding or updating tests
- **build**: Build system changes
- **ci**: CI configuration changes
- **chore**: Other changes (maintenance, etc.)
- **revert**: Revert a previous commit

### Quick Commit Functions

#### `gconv <type> <message> [scope]`
Create a conventional commit.

```bash
gconv feat "add user authentication"
# Result: feat: add user authentication

gconv fix "resolve login bug" auth
# Result: fix(auth): resolve login bug
```

#### Shorthand Functions

```bash
gfeat "add dark mode"          # feat: add dark mode
gfix "resolve crash on startup" # fix: resolve crash on startup
gdocs "update API documentation" # docs: update API documentation
grefactor "simplify database queries" # refactor: simplify database queries
gtest "add unit tests for auth" # test: add unit tests for auth
gchore "update dependencies" # chore: update dependencies
gperf "optimize image loading" # perf: optimize image loading
```

### Examples

```bash
# Simple feature
gfeat "add password reset functionality"

# Feature with scope
gconv feat "implement JWT authentication" auth

# Bug fix
gfix "prevent null pointer in user service"

# Breaking change (use full git commit for body/footer)
git commit
# Then add in editor:
# feat(api): change authentication endpoint
#
# BREAKING CHANGE: /auth/login now requires email instead of username
```

---

## Commit Message Template

When you run `git commit` (without -m), you'll see a template with guidelines.

### Template Structure

```
# <type>(<scope>): <subject>
#
# <body>
#
# <footer>

# --- CONVENTIONAL COMMIT TYPES ---
# feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert

# --- GUIDELINES ---
# 1. Subject: imperative mood, lowercase, no period, max 50 chars
# 2. Scope: optional, in parentheses
# 3. Body: explain what and why (wrap at 72 chars)
# 4. Footer: references (Closes #123) or breaking changes
```

### Usage

```bash
git commit
# Opens editor with template
# Delete comment lines and write your commit message
```

---

## Git Hooks

Pre-commit hooks run automatically before each commit.

### Installation

**Global (recommended):**
```bash
git config --global core.hooksPath ~/.dotfiles/.config/git/hooks
```

**Per repository:**
```bash
cd /path/to/repo
cp ~/.dotfiles/.config/git/hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### Pre-Commit Checks

The pre-commit hook checks for:

1. **Merge conflict markers** - Prevents committing unresolved conflicts
2. **Debug statements** - Warns about console.log, debugger, pry, etc.
3. **Large files** - Prevents committing files >5MB
4. **Trailing whitespace** - Warns about whitespace issues
5. **Linter errors** - Runs ESLint, Rubocop, Black, Shellcheck if available

### Bypassing Hooks

Only when absolutely necessary:

```bash
git commit --no-verify -m "emergency fix"
```

---

## Tips and Tricks

### 1. Quick Status of All Projects

```bash
git-multi-status ~/projects
```

### 2. Clean Up Old Branches

```bash
# After merging PRs on GitHub
gfa  # Fetch and prune
git-cleanup-gone  # Delete local branches for deleted remotes
```

### 3. Safe Force Push

Always use `gpf` instead of `git push --force`:

```bash
gpf  # Safer than git push --force
```

### 4. Quick Fixes

```bash
# Forgot to add a file to last commit
ga file.txt
git-amend

# Want to undo last commit but keep changes
git-undo
```

### 5. Search Commit History

```bash
git-search "authentication"  # Find commits about authentication
```

### 6. Check What You're About to Push

```bash
git-unpushed  # See commits not yet pushed
```

### 7. Find Large Files

```bash
git-large-files  # Find the 20 largest files in history
```

### 8. Pretty Branch History

```bash
gbh  # Shows branches sorted by last commit date with colors
```

### 9. Quick Conventional Commits

```bash
# Instead of typing full commit message format
gfeat "add new feature"
gfix "resolve bug in login"
gdocs "update README"
```

---

## Workflow Example

Here's a typical workflow using these enhancements:

```bash
# Start new feature
gcb feature/dark-mode

# Make changes...
# (edit files)

# Add files (or use gap for interactive patch mode)
gaa

# Commit with conventional format
gfeat "add dark mode toggle to settings"

# Check what's different from main
git-unpushed

# Push and set upstream
gpsup

# Create PR on GitHub
# (use gh CLI or web interface)

# After PR is merged, cleanup
gco main
gl
git-cleanup-merged
```

---

## Configuration Files

- **Aliases**: `.zsh/aliases/.git.alias.zsh`
- **Functions**: `.zsh/functions/.git.func.zsh`
- **Commit Template**: `.config/git/.gitmessage`
- **Git Config**: `.config/git/.gitconfig`
- **Git Hooks**: `.config/git/hooks/`

---

## Learn More

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git Hooks Documentation](https://git-scm.com/docs/githooks)
- [fzf GitHub](https://github.com/junegunn/fzf)

---

**Happy Committing!** 🚀
