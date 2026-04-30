# Catppuccin Mocha palette overrides for Powerlevel10k (lean style)
# Sourced from .zshrc after ~/.p10k.zsh so these win.
# Color roles follow https://github.com/catppuccin/catppuccin/blob/main/docs/style-guide.md
#
# Mocha palette reference:
#   Rosewater #f5e0dc  Flamingo  #f2cdcd  Pink     #f5c2e7  Mauve    #cba6f7
#   Red       #f38ba8  Maroon    #eba0ac  Peach    #fab387  Yellow   #f9e2af
#   Green     #a6e3a1  Teal      #94e2d5  Sky      #89dceb  Sapphire #74c7ec
#   Blue      #89b4fa  Lavender  #b4befe
#   Text      #cdd6f4  Subtext1  #bac2de  Subtext0 #a6adc8
#   Overlay2  #9399b2  Overlay1  #7f849c  Overlay0 #6c7086

# ── Directory: path body → Lavender (terminal "Active Border" role),
#    anchors → Blue (Links/URLs role — "this is where you can navigate"),
#    shortened middle segments → Subtext 0 (sub-headline / muted text).
typeset -g POWERLEVEL9K_DIR_FOREGROUND='#b4befe'
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='#a6adc8'
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='#89b4fa'

# ── Git / VCS (success → Green, info → Teal, warning → Yellow)
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#a6e3a1'
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#94e2d5'
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#f9e2af'

# ── Last-command status (success → Green, error → Red)
typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND='#a6e3a1'
typeset -g POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND='#a6e3a1'
typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND='#f38ba8'
typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND='#f38ba8'
typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND='#f38ba8'

# ── Prompt character ❯ (Green ready / Red after failure)
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#a6e3a1'
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#f38ba8'

# ── Subtle / structural (Overlay 0 for separators, Subtext 0 for muted text)
typeset -g POWERLEVEL9K_RULER_FOREGROUND='#6c7086'
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND='#6c7086'
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='#a6adc8'

# ── Background jobs (mild warning → Peach)
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND='#fab387'

# ── direnv (warning → Yellow)
typeset -g POWERLEVEL9K_DIRENV_FOREGROUND='#f9e2af'

# ── Language version segments (asdf / native): per-language brand-ish colors
typeset -g POWERLEVEL9K_ASDF_FOREGROUND='#bac2de'
typeset -g POWERLEVEL9K_ASDF_RUBY_FOREGROUND='#f38ba8'      # Red
typeset -g POWERLEVEL9K_ASDF_PYTHON_FOREGROUND='#89b4fa'    # Blue
typeset -g POWERLEVEL9K_ASDF_GOLANG_FOREGROUND='#89dceb'    # Sky
typeset -g POWERLEVEL9K_ASDF_NODEJS_FOREGROUND='#a6e3a1'    # Green
typeset -g POWERLEVEL9K_ASDF_RUST_FOREGROUND='#fab387'      # Peach
typeset -g POWERLEVEL9K_ASDF_DOTNET_CORE_FOREGROUND='#cba6f7'
typeset -g POWERLEVEL9K_ASDF_FLUTTER_FOREGROUND='#74c7ec'
typeset -g POWERLEVEL9K_ASDF_LUA_FOREGROUND='#89b4fa'
typeset -g POWERLEVEL9K_ASDF_JAVA_FOREGROUND='#fab387'
typeset -g POWERLEVEL9K_ASDF_PERL_FOREGROUND='#cba6f7'
typeset -g POWERLEVEL9K_ASDF_ERLANG_FOREGROUND='#f38ba8'
typeset -g POWERLEVEL9K_ASDF_ELIXIR_FOREGROUND='#cba6f7'
typeset -g POWERLEVEL9K_ASDF_POSTGRES_FOREGROUND='#89b4fa'
typeset -g POWERLEVEL9K_ASDF_PHP_FOREGROUND='#cba6f7'
typeset -g POWERLEVEL9K_ASDF_HASKELL_FOREGROUND='#cba6f7'
typeset -g POWERLEVEL9K_ASDF_JULIA_FOREGROUND='#cba6f7'

# Tell p10k to re-render with new values if it's already loaded.
(( ${+functions[p10k]} )) && p10k reload
