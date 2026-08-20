#!/usr/bin/env bats
#
# DDEV add-on test. Requires: bats, docker, ddev, and a PUBLISHED release + GHCR image
# (the add-on downloads docs.db.gz from the latest release and pulls the server image).
#
# Run:  bats ./tests/test.bats

setup() {
  set -eu -o pipefail
  export DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd)"
  export TESTDIR=$(mktemp -d)
  export PROJNAME="test-agent-module-knowledge-mcp"
  export DDEV_NONINTERACTIVE=true
  cd "$TESTDIR"
  ddev config --project-name="$PROJNAME" --project-type=php
  ddev start -y >/dev/null
}

teardown() {
  set -eu -o pipefail
  cd "$TESTDIR" || true
  ddev delete -Oy "$PROJNAME" >/dev/null 2>&1 || true
  [ -n "${TESTDIR:-}" ] && rm -rf "$TESTDIR"
}

@test "install from directory and reach the MCP endpoint" {
  set -eu -o pipefail
  cd "$TESTDIR"
  ddev add-on get "$DIR"
  ddev restart -y >/dev/null

  # The service container should be up.
  ddev exec -s agent-module-docs true

  # /mcp should respond to an MCP initialize (405/406/200 are all "endpoint is alive").
  run curl -sk -o /dev/null -w "%{http_code}" "https://${PROJNAME}.ddev.site:9131/mcp"
  [ "$status" -eq 0 ]
  echo "status: $output"
  [[ "$output" =~ ^(200|400|405|406)$ ]]
}
