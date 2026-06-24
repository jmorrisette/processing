#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <SketchName>" >&2
  exit 1
fi

SKETCH="$1"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKETCH_PATH="$REPO_ROOT/Collection/$SKETCH"
PDE_FILE="$SKETCH_PATH/$SKETCH.pde"

if [[ ! -d "$SKETCH_PATH" ]]; then
  echo "Sketch not found: $SKETCH_PATH" >&2
  echo "Create Collection/$SKETCH/$SKETCH.pde first." >&2
  exit 1
fi

if [[ ! -f "$PDE_FILE" ]]; then
  echo "Main sketch file not found: $PDE_FILE" >&2
  exit 1
fi

find_processing() {
  to_unix_path() {
    local path="$1"
    if [[ "$path" =~ ^[A-Za-z]:[/\\] ]]; then
      local drive
      drive="$(echo "${path:0:1}" | tr 'A-Z' 'a-z')"
      path="/${drive}${path:2}"
      path="${path//\\//}"
    fi
    printf '%s' "$path"
  }

  local candidates=()

  if [[ -n "${PROCESSING_HOME:-}" ]]; then
    local home
    home="$(to_unix_path "$PROCESSING_HOME")"
    candidates+=(
      "$home/Processing.exe"
      "$home/processing.exe"
      "$home/Processing"
      "$home/processing"
    )
  fi

  if [[ "$(uname -s 2>/dev/null)" =~ MINGW|MSYS|CYGWIN ]] || [[ "${OS:-}" == "Windows_NT" ]]; then
    candidates+=(
      "/c/Program Files/Processing/Processing.exe"
      "/c/Program Files/Processing/processing.exe"
    )
    if [[ -n "${PROGRAMFILES:-}" ]]; then
      local program_files
      program_files="$(to_unix_path "$PROGRAMFILES")"
      candidates+=(
        "$program_files/Processing/Processing.exe"
        "$program_files/Processing/processing.exe"
      )
    fi
    if [[ -n "${LOCALAPPDATA:-}" ]]; then
      local local_app_data
      local_app_data="$(to_unix_path "$LOCALAPPDATA")"
      candidates+=(
        "$local_app_data/Programs/Processing/Processing.exe"
        "$local_app_data/Programs/Processing/processing.exe"
      )
    fi
  fi

  if [[ "$(uname -s 2>/dev/null)" == "Darwin" ]]; then
    candidates+=("/Applications/Processing.app/Contents/MacOS/Processing")
  fi

  local candidate
  for candidate in "${candidates[@]}"; do
    if [[ -n "$candidate" && -x "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
  done

  if command -v processing >/dev/null 2>&1; then
    command -v processing
    return 0
  fi

  if command -v Processing.exe >/dev/null 2>&1; then
    command -v Processing.exe
    return 0
  fi

  if command -v processing-java >/dev/null 2>&1; then
    command -v processing-java
    return 0
  fi

  return 1
}

if ! PROCESSING_BIN="$(find_processing)"; then
  cat >&2 <<EOF
Processing was not found.

Install Processing 4 from https://processing.org/download
Then either:
  - add processing to your PATH, or
  - set PROCESSING_HOME to your Processing install directory

You can also open sketches in the IDE:
  File -> Open -> $PDE_FILE
EOF
  exit 1
fi

echo "Running $SKETCH with $PROCESSING_BIN"
"$PROCESSING_BIN" cli --sketch="$SKETCH_PATH" --run
