#!/usr/bin/env bash
# Full verification gate. Must pass before any commit.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
FAIL=0
step() { printf "\n\033[1m▸ %s\033[0m\n" "$1"; }
ok()   { printf "  \033[32m✔ %s\033[0m\n" "$1"; }
bad()  { printf "  \033[31m✘ %s\033[0m\n" "$1"; FAIL=1; }

step "Secrets check"
if git ls-files --error-unmatch contracts/.env >/dev/null 2>&1 \
   || git ls-files --error-unmatch frontend/.env.local >/dev/null 2>&1; then
  bad ".env IS TRACKED BY GIT — remove it immediately"
else
  ok "no .env tracked"
fi
if git grep -nIE '(PRIVATE_KEY|MNEMONIC)[[:space:]]*=[[:space:]]*(0x)?[A-Za-z0-9]{20,}' \
     -- . ':!*.example' ':!scripts/verify.sh' >/dev/null 2>&1; then
  bad "possible secret found in tracked files"
else
  ok "no secret-shaped strings in tracked files"
fi

step "Generated output not staged"
if git ls-files | grep -qE '^(contracts/)?(out|cache|broadcast)/'; then
  bad "build output is tracked — fix .gitignore"
else
  ok "no build output tracked"
fi

if [[ -d contracts ]]; then
  cd contracts
  step "Format"
  forge fmt --check >/dev/null 2>&1 && ok "formatted" || bad "run: forge fmt"
  step "Build"
  forge build >/dev/null 2>&1 && ok "compiles" || { bad "build failed"; forge build; }
  if ls test/**/*.t.sol >/dev/null 2>&1; then
    step "Tests"
    forge test && ok "tests pass" || bad "tests failed"
  fi
  cd "$ROOT"
fi

if [[ -f frontend/package.json ]]; then
  cd frontend
  step "Frontend typecheck"
  npm run -s typecheck 2>/dev/null && ok "types ok" || bad "typecheck failed"
  cd "$ROOT"
fi

echo
[[ $FAIL -eq 0 ]] && { printf "\033[32m ALL CHECKS PASSED \033[0m\n"; exit 0; }
printf "\033[31m VERIFICATION FAILED \033[0m\n"; exit 1
