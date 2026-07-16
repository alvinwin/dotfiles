#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
dry_run=false

if [[ ${1:-} == "--dry-run" ]]; then
  dry_run=true
elif [[ $# -gt 0 ]]; then
  printf 'usage: %s [--dry-run]\n' "$0" >&2
  exit 2
fi

run() {
  printf '+ '
  printf '%q ' "$@"
  printf '\n'
  if ! $dry_run; then
    "$@"
  fi
}

if [[ ! -r /etc/os-release ]]; then
  printf 'error: /etc/os-release is unavailable; Linux distribution cannot be detected\n' >&2
  exit 1
fi

# shellcheck disable=SC1091
source /etc/os-release
family=
case " ${ID:-} ${ID_LIKE:-} " in
  *" ubuntu "*|*" debian "*) family=ubuntu ;;
  *" fedora "*) family=fedora ;;
  *" arch "*) family=arch ;;
  *)
    printf 'error: unsupported distribution: %s\n' "${PRETTY_NAME:-unknown}" >&2
    exit 1
    ;;
esac

mapfile -t packages < <(grep -hvE '^[[:space:]]*(#|$)' \
  "$repo_dir/bootstrap/packages/common.txt" \
  "$repo_dir/bootstrap/packages/$family.txt")

printf 'distribution: %s (%s family)\n' "${PRETTY_NAME:-$ID}" "$family"
case "$family" in
  ubuntu) run sudo apt-get update; run sudo apt-get install -y "${packages[@]}" ;;
  fedora) run sudo dnf install -y "${packages[@]}" ;;
  arch) run sudo pacman -Syu --needed --noconfirm "${packages[@]}" ;;
esac

link_config() {
  local source=$1 target=$2
  if [[ -L $target && $(readlink -f -- "$target") == $(readlink -f -- "$source") ]]; then
    printf '= %s already linked\n' "$target"
  elif [[ -e $target || -L $target ]]; then
    printf '! preserving existing %s (link %s manually after reviewing it)\n' "$target" "$source"
  else
    run mkdir -p "$(dirname -- "$target")"
    run ln -s "$source" "$target"
  fi
}

add_include() {
  local file=$1 line=$2
  if [[ -f $file ]] && grep -Fqx -- "$line" "$file"; then
    printf '= %s already includes the tracked configuration\n' "$file"
  else
    printf '+ append to %s: %s\n' "$file" "$line"
    if ! $dry_run; then
      printf '\n%s\n' "$line" >> "$file"
    fi
  fi
}

add_git_include() {
  local file=$1 path=$2
  if [[ -f $file ]] && git config --file "$file" --get-all include.path 2>/dev/null | grep -Fqx -- "$path"; then
    printf '= %s already includes the tracked configuration\n' "$file"
  else
    run git config --file "$file" --add include.path "$path"
  fi
}

link_config "$repo_dir/.tmux.conf" "$HOME/.tmux.conf"
link_config "$repo_dir/tmux" "$HOME/.config/tmux"
link_config "$repo_dir/tmux-palette" "$HOME/.config/tmux-palette"
link_config "$repo_dir/nvim" "$HOME/.config/nvim"
link_config "$repo_dir/opencode" "$HOME/.config/opencode"
link_config "$repo_dir/kitty" "$HOME/.config/kitty"

add_include "$HOME/.bashrc" "source \"$repo_dir/shell/bashrc\""
add_git_include "$HOME/.gitconfig" "$repo_dir/git/gitconfig"

font_dir="$HOME/.local/share/fonts/MesloLGS-NF"
font_version=3.4.0
if grep -Fq 'MesloLGS Nerd Font Mono' < <(fc-list); then
  printf '= MesloLGS Nerd Font Mono already installed\n'
else
  run mkdir -p "$font_dir"
  font_archive="${TMPDIR:-/tmp}/Meslo-$font_version.zip"
  run curl -fL --retry 3 -o "$font_archive" \
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v$font_version/Meslo.zip"
  run unzip -jo "$font_archive" 'MesloLGSNerdFontMono-*.ttf' -d "$font_dir"
  run fc-cache -f "$font_dir"
fi

if command -v opencode >/dev/null 2>&1; then
  printf '= OpenCode already installed\n'
else
  printf '+ install OpenCode with the official installer\n'
  if ! $dry_run; then
    curl -fsSL https://opencode.ai/install | bash
  fi
fi

printf '\nBootstrap complete. Restart the shell and OpenCode before verifying.\n'
