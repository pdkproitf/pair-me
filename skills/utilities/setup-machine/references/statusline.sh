#!/usr/bin/env bash
# Claude Code status line: cship output + repo name + session name.
input=$(cat)
export SL_REPO=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null)
name=$(printf '%s' "$input" | python3 -c 'import sys,json
try:
 d=json.load(sys.stdin); print(d.get("session_name") or d.get("session_id") or "")
except Exception: pass' 2>/dev/null)
out=$(printf '%s' "$input" | cship | perl -pe 'BEGIN{$r=$ENV{SL_REPO}} s/(?<![;\d\[])(\d{4,})(?![;\dm\[])/sprintf("%.0fk",$1\/1000)/ge; s/( on \x1b\[1;35m)(.*?) (\S+)(\x1b\[0m)/$1$2 $r:$3$4/')
printf '%s' "$out"
[ -n "$name" ] && printf ' \033[38;5;250m%s\033[0m' "$name"
printf '\n'
