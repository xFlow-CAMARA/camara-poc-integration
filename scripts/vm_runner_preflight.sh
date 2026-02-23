#!/usr/bin/env bash
set -euo pipefail

# Preflight checks for the self-hosted runner VM.
# This is meant to fail fast with actionable messages.

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    return 1
  fi
}

header() {
  echo
  echo "==> $1"
}

ok() {
  echo "OK: $1"
}

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

header "Basic tools"
require_cmd git || fail "Install git (required for actions/checkout and repo updates)"
ok "git: $(git --version)"

require_cmd curl || fail "Install curl (required for runner + setup actions downloads)"
ok "curl: $(curl --version | head -n1)"

require_cmd tar || fail "Install tar (required by setup-* actions)"
require_cmd gzip || fail "Install gzip (required by setup-* actions)"
require_cmd unzip || fail "Install unzip (required by setup-* actions)"
# xz is commonly needed for toolchain archives (Go, Node)
require_cmd xz || fail "Install xz-utils/xz (recommended; commonly needed for toolchain archives)"
ok "archive tools present"

header "Docker"
require_cmd docker || fail "Install Docker Engine"

docker version >/dev/null 2>&1 || fail "Docker is installed but not usable by this user (check docker service and group membership)"
ok "docker engine usable"

# Compose v2 is a subcommand: docker compose
if ! docker compose version >/dev/null 2>&1; then
  fail "Docker Compose v2 not found (need 'docker compose'). Install compose plugin or upgrade Docker."
fi
ok "docker compose present"

header "Network egress"
# self-hosted runners must reach GitHub, plus registries for Docker pulls/pushes.
for url in \
  https://github.com \
  https://api.github.com \
  https://ghcr.io/v2/ \
  https://registry-1.docker.io/v2/

do
  # Note: registries commonly reply with 401/403/405 without auth; that's still
  # proof of connectivity. We only fail on connection-level problems.
  http_code="$(curl -sSIL --max-time 10 -o /dev/null -w '%{http_code}' "$url" || true)"
  if [ -z "${http_code:-}" ] || [ "$http_code" = "000" ]; then
    fail "cannot reach: $url (check DNS/proxy/firewall; Actions will fail)"
  fi
  ok "reachable: $url (HTTP $http_code)"
done

header "Disk space"
# Docker builds can be large; warn if very low.
avail_kb=$(df -Pk . | awk 'NR==2 {print $4}')
if [ -n "${avail_kb:-}" ] && [ "$avail_kb" -lt 5242880 ]; then
  # < 5GB
  echo "WARN: low free disk space (<5GB). Docker builds may fail." >&2
else
  ok "disk space looks ok"
fi

echo
echo "Preflight complete."
