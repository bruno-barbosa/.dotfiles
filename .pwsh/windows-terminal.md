# Windows Terminal

`bootstrap.ps1` deliberately does **not** rewrite `settings.json`. Windows
Terminal owns that file, rewrites it on every UI change, and clobbering it
would lose anything set through the GUI. Merge these by hand instead.

Settings live at:

    %LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json

## 1. Colour schemes and themes

Copy the four flavours from https://github.com/catppuccin/windows-terminal --
each flavour has a `<flavour>.json` (goes in `"schemes"`) and a
`<flavour>Theme.json` (goes in `"themes"`). They are two separate settings:
the scheme colours the text, the theme colours the tab row and titlebar.
Setting only one is the usual reason "the theme didn't work".

## 2. Top level

    "theme": "Catppuccin Mocha"

## 3. profiles.defaults

    "defaults": {
        "colorScheme": "Catppuccin Mocha",
        "font": { "face": "Maple Mono NF" },
        "opacity": 85,
        "useAcrylic": true
    }

`Maple Mono NF` -- the Nerd Font patched build, not plain `Maple Mono`.
Only the NF build has the prompt glyphs. `bootstrap.ps1` installs it via
the scoop `nerd-fonts` bucket.

`useAcrylic` blurs what is behind the window; drop it for clear
transparency instead of frosted.

## 4. Quake mode (optional)

Add to `"actions"` for a drop-down terminal on Win+backtick:

    {
        "command": {
            "action": "globalSummon",
            "name": "_quake",
            "desktop": "toCurrent",
            "monitor": "toMouse",
            "dropdownDuration": 200,
            "toggleVisibility": true
        },
        "keys": "win+`"
    }