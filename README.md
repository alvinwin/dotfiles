# Dotfiles

Personal tmux and Neovim configuration for a terminal-first WSL development
environment.

## Layout

| Repository path | Live path |
| --- | --- |
| `.tmux.conf` | `~/.tmux.conf` |
| `tmux/` | `~/.config/tmux/` |
| `nvim/` | `~/.config/nvim/` |

The tracked files are the source of truth. The live paths may be symlinked to
the repository after any existing files have been backed up:

```sh
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/tmux ~/.config/tmux
ln -s ~/dotfiles/nvim ~/.config/nvim
```

## Tmux

- Mouse support and vi-style copy mode
- Vim-style pane navigation and resizing
- Fuzzy switching across sessions with `prefix P`
- WSL clipboard integration through `win32yank.exe`
- Rosé Pine Main/Dawn switching based on terminal events or time
- Rosé Pine, Dawn, and plain manual choices under `prefix T`
- tmux-thumbs integration for selecting paths, URLs, hashes, and numbers

The tmux-thumbs plugin is installed separately at
`~/.tmux/plugins/tmux-thumbs`.

## Neovim

- WSL clipboard integration through `win32yank.exe`
- lazy.nvim plugin management
- Telescope, Harpoon, Flash, WhichKey, Gitsigns, Markview, Smear Cursor, and Hardtime
- Rosé Pine synchronized with the active tmux variant
- Minimal lualine status display

Neovim installs lazy.nvim and the declared plugins on first launch. Plugin
versions are recorded in `nvim/lazy-lock.json`.
