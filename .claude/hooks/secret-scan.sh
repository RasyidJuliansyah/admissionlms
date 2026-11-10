#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash). Memblokir `git commit` kalau staged diff
# berisi pola yang mirip secret. Exit 2 = blokir, pesan stderr dikirim ke Claude.
input="$(cat)"
echo "$input" | grep -q 'git commit' || exit 0

patterns='(AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9_-]{20,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|(api[_-]?key|secret|password|token)["'"'"' ]*[:=]["'"'"' ]*[A-Za-z0-9/+_-]{12,})'
hits="$(git diff --cached -U0 2>/dev/null | grep '^+' | grep -Ei "$patterns" | head -5)"
if [ -n "$hits" ]; then
  echo "Commit diblokir: staged diff berisi pola yang mirip secret. Pindahkan nilainya ke .env lalu ulangi." >&2
  echo "$hits" >&2
  exit 2
fi
exit 0
