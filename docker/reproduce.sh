#!/usr/bin/env bash
# Download the QKD Studio reproduction image for this machine, verify it, and run it.
#
#   bash docker/reproduce.sh [output-directory]      # default: ./qkd-output
#
# The image runs every experiment of the paper with the compiled engine and compares
# fourteen regenerated tables and data files with the reported values. Tables, data
# and figures are written to the output directory. Needs Docker and curl.
set -euo pipefail

VERSION="0.3.0"
IMAGE="qkd-studio-repro:$VERSION"
RELEASE="https://github.com/muntakim1/qkd-geo-simulator/releases/download/v$VERSION"
OUTPUT="${1:-$PWD/qkd-output}"

case "$(uname -m)" in
  x86_64 | amd64) ARCH="amd64" ;;
  arm64 | aarch64) ARCH="arm64" ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac
ARCHIVE="qkd-studio-repro_${VERSION}_linux-${ARCH}.tar.gz"

if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  WORK="$(mktemp -d)"
  trap 'rm -rf "$WORK"' EXIT
  echo "Downloading $ARCHIVE"
  curl -fL --progress-bar -o "$WORK/$ARCHIVE" "$RELEASE/$ARCHIVE"
  curl -fsSL -o "$WORK/SHA256SUMS.txt" "$RELEASE/SHA256SUMS.txt"
  EXPECTED="$(grep " $ARCHIVE\$" "$WORK/SHA256SUMS.txt" | cut -d' ' -f1)"
  if command -v sha256sum >/dev/null 2>&1; then
    ACTUAL="$(sha256sum "$WORK/$ARCHIVE" | cut -d' ' -f1)"
  else
    ACTUAL="$(shasum -a 256 "$WORK/$ARCHIVE" | cut -d' ' -f1)"
  fi
  if [[ -z "$EXPECTED" || "$EXPECTED" != "$ACTUAL" ]]; then
    echo "Checksum mismatch for $ARCHIVE" >&2
    exit 1
  fi
  docker load -i "$WORK/$ARCHIVE"
fi

mkdir -p "$OUTPUT"
docker run --rm -v "$OUTPUT:/output" "$IMAGE"
echo "Results are in $OUTPUT"
