# Dotfiles

Personal dotfiles for macOS and Linux. Strongly inspired by [JDevlieghere/dotfiles](https://github.com/JDevlieghere/dotfiles).

## What's Included

| File / Directory | Description |
|---|---|
| `.zshrc` | Zsh configuration with Oh-My-Zsh |
| `.aliases` | Shell aliases |
| `.exports` | Environment variables |
| `.exports.local` | Local environment overrides (not synced) |
| `.gitconfig.template` | Git configuration template (used to generate `.gitconfig`) |
| `.gitignore_global` | Global gitignore rules |
| `.tmux.conf` | tmux configuration |
| `.vimrc` | Vim configuration |
| `.alacritty.toml` | Alacritty terminal config |
| `.ghostty` | Ghostty terminal config |
| `.aerospace.toml` | AeroSpace window manager config |
| `.mise.toml` | mise (runtime version manager) config |
| `.editorconfig` | Editor defaults |
| `Brewfile` | Homebrew packages and casks |
| `os/macos.sh` | macOS system preferences |
| `os/linux.sh` | Linux system preferences |
| `fonts/` | Font installation (FiraCode) |
| `themes/` | Custom ZSH themes (modified af-magic) |

## Installation

Clone the repository and run the bootstrap script:

```bash
git clone https://github.com/paniko0/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles
./bootstrap.sh
```

Running without arguments executes all steps. You can also run individual steps:

```
Usage: bootstrap.sh [options]

   -s, --sync             Synchronize dotfiles to home directory
   -t, --themes           Synchronize ZSH themes
   -l, --link             Create symbolic links
   -i, --install          Install extra software
   -f, --fonts            Copy font files
   -c, --config           Configure system (macOS/Linux defaults)
   -g, --gitconfig        Force reconfigure git identity
   -a, --all              Do everything (default)
```

## Bootstrap Steps

When running with `--all` (or no arguments), the script performs these steps in order:

1. **Update** -- pulls the latest changes from the repo
2. **Brew** -- installs Homebrew (if missing) and all packages from `Brewfile`
3. **Sync** -- rsyncs dotfiles to the home directory
4. **Themes** -- copies custom ZSH themes to Oh-My-Zsh
5. **Git** -- prompts for name, email, and GitHub username to generate `.gitconfig` (skipped if already configured)
6. **Directories** -- creates required directories (e.g., `~/.vim/undo`)
7. **Symlink** -- creates symbolic links for configs that should stay in sync
8. **Install** -- installs Oh-My-Zsh, zsh-autosuggestions, vim-plug, tpm, Neovim (kickstart), Alacritty themes, and programming languages via mise
9. **Fonts** -- installs FiraCode and any bundled fonts
10. **Config** -- applies OS-specific system preferences

## Symlinked Files

These files are symlinked (rather than copied) so edits in the repo are immediately reflected:

- `.zshrc`, `.aliases`, `.exports`, `.mise.toml`
- `.alacritty.toml`, `.ghostty`, `.aerospace.toml`, `.tmux.conf`

## Git Configuration

`.gitconfig` is generated from `.gitconfig.template` during bootstrap. On a fresh install, you'll be prompted for:

- **Full name** (pre-filled from your OS user profile)
- **Email**
- **GitHub username**

If `~/.gitconfig` already exists, the prompt is skipped. To force reconfiguration:

```bash
./bootstrap.sh --gitconfig
```

## Local Overrides

- **`.exports.local`** -- copied (not symlinked) on first sync; add machine-specific environment variables here
- **`.aliases.local`** -- created as an empty file on first sync; add machine-specific aliases here

These files are not tracked by git.

## macOS Defaults

The `os/macos.sh` script configures:

- Fast keyboard repeat rate
- Disabled mouse acceleration
- Finder: show status bar, path bar, POSIX path, list view by default
- Dock: small tile size (24px) with magnification (80px)
- Disabled smart quotes and dashes
- Password required immediately after sleep
- Prevents `.DS_Store` on network volumes
- Shows `~/Library` and `/Volumes`

## Key Software

Installed via Brewfile:

- **Terminals**: Ghostty, iTerm2, Alacritty
- **Editors**: Neovim, VS Code
- **Browser**: Google Chrome, Zen
- **Dev tools**: Docker Desktop, TablePlus, mise, gh
- **Fonts**: FiraCode, FiraCode Nerd Font
- **Other**: Slack, Spotify, Zoom, Rectangle
