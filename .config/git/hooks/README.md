# Git Hooks

This directory contains reusable git hooks that can be installed in your repositories.

## Available Hooks

### pre-commit

Runs before each commit to check for:
- Merge conflict markers
- Debugging statements (console.log, debugger, pry, etc.)
- Large files (>5MB)
- Trailing whitespace
- Linter errors (ESLint, Rubocop, Black, Shellcheck)

## Installation

### Option 1: Per Repository

Install the hook in a specific repository:

```bash
cd /path/to/your/repo
cp ~/.dotfiles/.config/git/hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### Option 2: Global Configuration (Recommended)

Configure git to use these hooks for all repositories:

```bash
git config --global core.hooksPath ~/.dotfiles/.config/git/hooks
```

**Note:** This will use these hooks for ALL repositories. You can override this per-repository:

```bash
cd /path/to/specific/repo
git config core.hooksPath .git/hooks  # Use local hooks instead
```

## Customizing Hooks

The pre-commit hook contains several checks that are currently warnings. You can make them hard fails by uncommenting the relevant `CHECKS_FAILED=1` lines.

For example, to make debug statements a hard fail:

```bash
# Change this:
if git diff --cached --name-only | xargs grep -l -E "$pattern" 2>/dev/null; then
  echo -e "${YELLOW}⚠  Warning: Found '$pattern' in staged files${NC}"
  # Uncomment to make this a hard fail:
  # CHECKS_FAILED=1
fi

# To this:
if git diff --cached --name-only | xargs grep -l -E "$pattern" 2>/dev/null; then
  echo -e "${RED}✗ Found '$pattern' in staged files${NC}"
  CHECKS_FAILED=1
fi
```

## Bypassing Hooks

If you need to bypass the pre-commit hook for a specific commit:

```bash
git commit --no-verify -m "emergency fix"
```

**Warning:** Only use `--no-verify` when absolutely necessary!

## Adding More Hooks

You can add more hooks to this directory:

- `pre-push` - Runs before git push
- `commit-msg` - Validates commit messages
- `post-commit` - Runs after a successful commit
- `prepare-commit-msg` - Modifies the commit message template

See [Git Hooks Documentation](https://git-scm.com/docs/githooks) for more information.
