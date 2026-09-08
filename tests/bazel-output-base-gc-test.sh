#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GC="$SCRIPT_DIR/../bin/bazel-output-base-gc"
TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/bazel-output-base-gc-test.XXXXXX")"
ROOT="$TEST_DIR/_bazel_test"

cleanup() {
  find "$TEST_DIR" -type d -exec chmod u+w {} + 2>/dev/null || true
  find "$TEST_DIR" -depth -delete 2>/dev/null || true
}
trap cleanup EXIT

make_base() {
  local id="$1"
  local workspace="$2"
  local pid="${3:-}"

  mkdir -p "$ROOT/$id/server"
  printf 'WORKSPACE: %s\n' "$workspace" > "$ROOT/$id/README"
  dd if=/dev/zero of="$ROOT/$id/payload" bs=1024 count=4 2>/dev/null
  if [[ -n "$pid" ]]; then
    printf '%s\n' "$pid" > "$ROOT/$id/server/server.pid.txt"
  fi
}

mkdir -p "$ROOT"
inactive_id="11111111111111111111111111111111"
active_id="22222222222222222222222222222222"
regular_id="33333333333333333333333333333333"

make_base "$inactive_id" "/private/var/folders/aa/T/opencode/inactive"
make_base "$active_id" "/private/var/folders/aa/T/opencode/active" "$$"
make_base "$regular_id" "$HOME/work/regular"

dry_run_output="$($GC --root "$ROOT" --max-total-gib 0 --min-age-hours 0)"
grep -q "\[PLAN" <<< "$dry_run_output"
[[ -d "$ROOT/$inactive_id" ]]

mkdir -p "$ROOT/.bazel-output-base-gc-interrupted"
printf 'partial\n' > "$ROOT/.bazel-output-base-gc-interrupted/payload"
apply_output="$($GC --apply --root "$ROOT" --max-total-gib 0 --min-age-hours 0)"
grep -q "\[RESUME" <<< "$apply_output"
grep -q "\[DELETED" <<< "$apply_output"
[[ ! -e "$ROOT/$inactive_id" ]]
[[ -d "$ROOT/$active_id" ]]
[[ -d "$ROOT/$regular_id" ]]
[[ -z "$(find "$ROOT" -mindepth 1 -maxdepth 1 -type d -name '.bazel-output-base-gc-*' -print)" ]]

recent_id="44444444444444444444444444444444"
make_base "$recent_id" "/private/var/folders/aa/T/opencode/recent"
recent_output="$($GC --apply --root "$ROOT" --max-total-gib 0 --min-age-hours 1)"
grep -q "is recent" <<< "$recent_output"
[[ -d "$ROOT/$recent_id" ]]

if "$GC" --root "$ROOT" --max-total-gib invalid >"$TEST_DIR/error.out" 2>&1; then
  echo "expected invalid numeric argument to fail" >&2
  exit 1
fi
grep -q "must be a non-negative integer" "$TEST_DIR/error.out"

echo "bazel-output-base-gc tests passed"
