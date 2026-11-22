#!/usr/bin/env bash
# Prints "<short sink name> <volume>%" for the default sink, updating on changes.
# Short name = first + last word of the sink description, e.g. "Bose Earbuds".

print_status() {
  local sink desc vol mute short
  sink=$(pactl get-default-sink 2>/dev/null) || return
  desc=$(pactl list sinks | awk -v s="$sink" '
    $1 == "Name:" { found = ($2 == s) }
    found && /Description:/ { sub(/^[^:]*: /, ""); print; exit }')
  vol=$(pactl get-sink-volume "$sink" | grep -Po '\d+%' | head -n1)
  mute=$(pactl get-sink-mute "$sink" | awk '{print $2}')
  read -r -a words <<< "$desc"
  if (( ${#words[@]} > 1 )); then
    short="${words[0]} ${words[-1]}"
  else
    short="${words[0]:-?}"
  fi
  short="${short:0:14}"
  if [[ "$mute" == "yes" ]]; then
    echo "$short: muted"
  else
    echo "$short: $vol"
  fi
}

print_status
pactl subscribe 2>/dev/null | grep --line-buffered -E "'change' on (sink|server)" |
  while read -r _; do print_status; done
