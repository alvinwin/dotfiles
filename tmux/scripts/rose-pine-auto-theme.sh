#!/usr/bin/env bash
set -u

tmux_bin="${TMUX_BIN:-tmux}"
theme_dir="${TMUX_ROSE_PINE_THEME_DIR:-$HOME/.config/tmux/themes}"

tmux_get() {
  "$tmux_bin" show-option -gqv "$1" 2>/dev/null || true
}

valid_hour() {
  case "$1" in
    ''|*[!0-9]*) return 1 ;;
  esac
  [ "$1" -ge 0 ] && [ "$1" -le 23 ]
}

choose_mode() {
  local day_start night_start hour

  day_start="$(tmux_get @rose_pine_day_start)"
  night_start="$(tmux_get @rose_pine_night_start)"
  valid_hour "$day_start" || day_start=7
  valid_hour "$night_start" || night_start=18

  hour="$(date +%H)"
  hour=$((10#$hour))

  if [ "$day_start" -le "$night_start" ]; then
    if [ "$hour" -ge "$day_start" ] && [ "$hour" -lt "$night_start" ]; then
      printf '%s\n' dawn
    else
      printf '%s\n' dark
    fi
  elif [ "$hour" -ge "$day_start" ] || [ "$hour" -lt "$night_start" ]; then
    printf '%s\n' dawn
  else
    printf '%s\n' dark
  fi
}

apply_theme() {
  local auto mode theme_file

  auto="$(tmux_get @rose_pine_auto_theme)"
  auto="${auto:-on}"
  [ "$auto" = "on" ] || return 0

  mode="$(choose_mode)"
  case "$mode" in
    dawn) theme_file="$theme_dir/rose-pine-dawn.conf" ;;
    dark) theme_file="$theme_dir/rose-pine-dark.conf" ;;
    *) return 1 ;;
  esac

  [ -r "$theme_file" ] || return 1
  "$tmux_bin" source-file "$theme_file"
}

watch_theme() {
  local interval pidfile old_pid

  interval="$(tmux_get @rose_pine_check_interval)"
  case "$interval" in
    ''|*[!0-9]*) interval=300 ;;
  esac
  [ "$interval" -ge 30 ] || interval=300

  pidfile="${TMPDIR:-/tmp}/tmux-rose-pine-auto-theme-${UID}.pid"
  if [ -r "$pidfile" ]; then
    old_pid="$(cat "$pidfile" 2>/dev/null || true)"
    case "$old_pid" in
      ''|*[!0-9]*) ;;
      *) kill -0 "$old_pid" 2>/dev/null && return 0 ;;
    esac
  fi

  printf '%s\n' "$$" >"$pidfile"
  trap 'rm -f "$pidfile"' EXIT

  while "$tmux_bin" has-session >/dev/null 2>&1; do
    apply_theme || true
    sleep "$interval"
  done
}

case "${1:---apply}" in
  --apply) apply_theme ;;
  --watch) watch_theme ;;
  --mode) choose_mode ;;
  *) printf 'usage: %s [--apply|--watch|--mode]\n' "$0" >&2; exit 2 ;;
esac
