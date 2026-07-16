#!/usr/bin/env bash

set -u

command -v fzf >/dev/null 2>&1 || {
  printf 'pane picker requires fzf\n' >&2
  exit 1
}

result=$(
  tmux list-panes -a -F '#{pane_id}|#{session_name}:#{window_index}.#{pane_index}|#{pane_current_command}|#{pane_title}|#{pane_current_path}' |
    fzf \
      --delimiter='|' \
      --with-nth=2.. \
      --prompt='SEARCH> ' \
      --header='esc: nav | j/k: move | i or /: search | enter: jump | ctrl-x: close pane | alt-x: close window' \
      --layout=reverse \
      --border \
      --expect=enter,ctrl-x,alt-x \
      --bind 'esc:disable-search+change-prompt(NAV> )' \
      --bind 'i:transform:if [[ $FZF_INPUT_STATE == disabled ]]; then echo "enable-search+change-prompt(SEARCH> )"; else echo "put(i)"; fi' \
      --bind '/:transform:if [[ $FZF_INPUT_STATE == disabled ]]; then echo "enable-search+change-prompt(SEARCH> )"; else echo "put(/)"; fi' \
      --bind 'j:transform:if [[ $FZF_INPUT_STATE == disabled ]]; then echo down; else echo "put(j)"; fi' \
      --bind 'k:transform:if [[ $FZF_INPUT_STATE == disabled ]]; then echo up; else echo "put(k)"; fi' \
      --bind 'g:transform:if [[ $FZF_INPUT_STATE == disabled ]]; then echo first; else echo "put(g)"; fi' \
      --bind 'G:transform:if [[ $FZF_INPUT_STATE == disabled ]]; then echo last; else echo "put(G)"; fi' \
      --bind 'ctrl-d:transform:if [[ $FZF_INPUT_STATE == disabled ]]; then echo half-page-down; else echo delete-char; fi' \
      --bind 'ctrl-u:transform:if [[ $FZF_INPUT_STATE == disabled ]]; then echo half-page-up; else echo unix-line-discard; fi' \
      --bind 'q:transform:if [[ $FZF_INPUT_STATE == disabled ]]; then echo abort; else echo "put(q)"; fi'
) || exit 0

action=${result%%$'\n'*}
selection=${result#*$'\n'}
pane_id=${selection%%|*}

case "$action" in
  ctrl-x)
    target=$(tmux display-message -p -t "$pane_id" '#{session_name}:#{window_index}.#{pane_index}')
    tmux confirm-before -p "Close pane $target? (y/n)" "kill-pane -t '$pane_id'"
    ;;
  alt-x)
    window_id=$(tmux display-message -p -t "$pane_id" '#{window_id}')
    target=$(tmux display-message -p -t "$pane_id" '#{session_name}:#{window_index}')
    tmux confirm-before -p "Close window $target? (y/n)" "kill-window -t '$window_id'"
    ;;
  *)
    tmux switch-client -t "$pane_id"
    tmux select-window -t "$pane_id"
    tmux select-pane -t "$pane_id"
    ;;
esac
