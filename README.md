# Dotfiles

Personal tmux and Neovim configuration for a terminal-first WSL development
environment.

## Layout

| Repository path | Live path |
| --- | --- |
| `.tmux.conf` | `~/.tmux.conf` |
| `tmux/` | `~/.config/tmux/` |
| `tmux-palette/` | `~/.config/tmux-palette/` |
| `nvim/` | `~/.config/nvim/` |

The tracked files are the source of truth. The live paths may be symlinked to
the repository after any existing files have been backed up:

```sh
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/tmux ~/.config/tmux
ln -s ~/dotfiles/tmux-palette ~/.config/tmux-palette
ln -s ~/dotfiles/nvim ~/.config/nvim
```

## Tmux

- Mouse support and vi-style copy mode
- Vim-style pane navigation and resizing
- Context-rich native session and window trees under `prefix s` and `prefix w`
- Clean/default tree view toggle under `prefix v`
- Fuzzy pane switching under `prefix f`
- Searchable tmux command palette under `prefix ?`
- WSL clipboard integration through `win32yank.exe`
- Rosé Pine Main/Dawn switching based on terminal events or time
- Rosé Pine, Dawn, and plain manual choices under `prefix T`
- tmux-thumbs integration for selecting paths, URLs, hashes, and numbers

The tmux-thumbs plugin is installed separately at
`~/.tmux/plugins/tmux-thumbs`.

### Tmux Palette

The command palette is pinned to commit
`7caa11e845e0aa0515d013158df85613f3ec507f` and requires Bun `1.3.14`.
Install Bun without modifying the system package database:

```sh
gh release download bun-v1.3.14 \
  --repo oven-sh/bun \
  --pattern bun-linux-x64.zip \
  --dir /tmp
bsdtar -xf /tmp/bun-linux-x64.zip -C /tmp
install -m 755 /tmp/bun-linux-x64/bun ~/.local/bin/bun
```

Install the pinned palette and its development dependencies:

```sh
git clone https://github.com/eduwass/tmux-palette ~/.tmux/plugins/tmux-palette
git -C ~/.tmux/plugins/tmux-palette checkout 7caa11e845e0aa0515d013158df85613f3ec507f
bun install --cwd ~/.tmux/plugins/tmux-palette --frozen-lockfile
```

Palette behavior and theme settings are tracked under `tmux-palette/`. To
remove the integration, remove the `?` and `f` bindings from `.tmux.conf`, unlink
`~/.config/tmux-palette`, and delete the plugin checkout. Bun can remain for
other tools or be removed separately from `~/.local/bin/bun`.

## Neovim

- WSL clipboard integration through `win32yank.exe`
- Terminal-wrapped prose cleanup with `<leader>cl`
- Response composition below the current line or visual selection with `<leader>cr`
- lazy.nvim plugin management
- Telescope, Harpoon, Flash, WhichKey, Gitsigns, Markview, Smear Cursor, and Hardtime
- Rosé Pine synchronized with the active tmux variant
- Minimal lualine status display

Neovim installs lazy.nvim and the declared plugins on first launch. Plugin
versions are recorded in `nvim/lazy-lock.json`.
