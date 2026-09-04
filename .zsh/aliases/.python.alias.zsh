# PYTHON ALIASES
#
# Everything here goes through uv: it is the version manager, the package
# manager and the tool runner. There is deliberately no bare `pip` alias --
# outside a virtualenv the system pip is either missing or blocked by
# PEP 668, and `uv pip` works on the project environment instead.

# project dependencies
alias uva='uv add'
alias uvr='uv remove'
alias uvs='uv sync'
alias uvl='uv lock'
alias uvrun='uv run'

# No `uvx` alias: uv ships uvx as a real binary (`uvx ruff check .` runs a
# tool in a throwaway environment without installing it).

# global CLI tools (the pipx equivalent)
alias uvt='uv tool list'
alias uvti='uv tool install'
alias uvtu='uv tool upgrade --all'

# interpreters
alias uvp='uv python list'
alias uvpi='uv python install'

# a REPL on the managed Python, with no project in sight
alias py='uv run --no-project python'
