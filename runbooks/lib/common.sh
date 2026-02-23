#!/usr/bin/env bash

# Shared helper library for runbooks.
# - Works both from system install (/usr/local/lib/sg-runbook/lib/common.sh)
#   and in-repo fallback (runbooks/lib/common.sh).

RB_LOG_DIR="${RB_LOG_DIR:-/var/log/sg-runbook}"
RB_ORIG_ARGS=("$@")

_rb_now() { date +%Y%m%d_%H%M%S; }
timestamp() { _rb_now; }

_sg_has_help_flag() {
  local arg
  for arg in "${RB_ORIG_ARGS[@]:-}"; do
    case "$arg" in
      -h|--help) return 0 ;;
    esac
  done
  return 1
}

log() { echo "[INFO] $*"; }
warn() { echo "[WARN] $*" >&2; }
die() { echo "[ERROR] $*" >&2; exit 1; }

run() {
  log "+ $*"
  "$@"
}

have_cmd() { command -v "$1" >/dev/null 2>&1; }

require_root() {
  # Keep --help usable in clone-only/non-root environments.
  if _sg_has_help_flag; then
    return 0
  fi
  [[ ${EUID:-$(id -u)} -eq 0 ]] || die "run as root"
}

ensure_log_dir() {
  local dir="${1:-$RB_LOG_DIR}"
  mkdir -p "$dir"
  RB_LOG_DIR="$dir"
}

_sg_realpath() {
  local p="$1"
  if have_cmd realpath; then
    realpath -m -- "$p"
    return
  fi
  if have_cmd readlink; then
    readlink -f -- "$p"
    return
  fi
  python3 - <<'PY' "$p"
import os, sys
print(os.path.realpath(sys.argv[1]))
PY
}

_sg_is_under() {
  local path="$1"
  local root="$2"
  [[ -n "$root" ]] || return 1
  case "$path" in
    "$root"|"$root"/*) return 0 ;;
    *) return 1 ;;
  esac
}

_sg_is_dangerous_path() {
  local p="$1"
  local home
  home="${HOME:-}"

  [[ -n "$p" ]] || return 0
  [[ "$p" != "/" ]] || return 0

  if [[ -n "$home" ]]; then
    [[ "$p" != "$home" ]] || return 0
    [[ "$p" != "$home/" ]] || return 0
  fi

  case "$p" in
    "/bin"|"/boot"|"/dev"|"/etc"|"/home"|"/lib"|"/lib64"|"/opt"|"/proc"|"/root"|"/run"|"/sbin"|"/srv"|"/sys"|"/tmp"|"/usr"|"/var")
      return 0
      ;;
  esac
  return 1
}

_sg_default_rm_roots() {
  local roots=()

  if [[ -n "${SG_PREFIX:-}" ]]; then
    roots+=("$(_sg_realpath "$SG_PREFIX")")
  fi

  roots+=(
    "/opt/sg"
    "/opt/sg-demos"
    "/opt/sg-images"
    "/var/backups/sg-runbook"
    "/var/log/sg-runbook"
  )

  if [[ -n "${SG_SAFE_RM_EXTRA_ROOTS:-}" ]]; then
    local extra
    IFS=':' read -r -a extra <<<"$SG_SAFE_RM_EXTRA_ROOTS"
    roots+=("${extra[@]}")
  fi

  printf '%s\n' "${roots[@]}"
}

_sg_is_allowed_rm_target() {
  local target="$1"
  shift || true

  local root
  while IFS= read -r root; do
    [[ -n "$root" ]] || continue
    root="$(_sg_realpath "$root")"
    if _sg_is_under "$target" "$root"; then
      return 0
    fi
  done < <(_sg_default_rm_roots)

  for root in "$@"; do
    [[ -n "$root" ]] || continue
    root="$(_sg_realpath "$root")"
    if _sg_is_under "$target" "$root"; then
      return 0
    fi
  done

  return 1
}

sg_safe_rm_dir() {
  local target_raw="${1:-}"
  shift || true

  [[ -n "$target_raw" ]] || die "sg_safe_rm_dir: empty path"
  local target
  target="$(_sg_realpath "$target_raw")"

  if _sg_is_dangerous_path "$target"; then
    die "sg_safe_rm_dir: refused dangerous path: $target"
  fi

  if [[ ! -e "$target" ]]; then
    log "sg_safe_rm_dir: not found (skip): $target"
    return 0
  fi

  if ! _sg_is_allowed_rm_target "$target" "$@"; then
    die "sg_safe_rm_dir: target outside allowed roots: $target"
  fi

  rm -rf -- "$target"
  log "sg_safe_rm_dir: removed $target"
}

sg_safe_rm_file() {
  local target_raw="${1:-}"
  shift || true

  [[ -n "$target_raw" ]] || die "sg_safe_rm_file: empty path"
  local target
  target="$(_sg_realpath "$target_raw")"

  if _sg_is_dangerous_path "$target"; then
    die "sg_safe_rm_file: refused dangerous path: $target"
  fi

  if [[ ! -e "$target" ]]; then
    log "sg_safe_rm_file: not found (skip): $target"
    return 0
  fi

  if ! _sg_is_allowed_rm_target "$target" "$@"; then
    die "sg_safe_rm_file: target outside allowed roots: $target"
  fi

  rm -f -- "$target"
  log "sg_safe_rm_file: removed $target"
}
