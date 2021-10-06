#!/bin/bash

set -euxo pipefail

sudo mkdir -p /opt/nix/{store,var}
sudo chown "$(id -u):$(id -g)" /opt/nix/{store,var}

nix-build --max-jobs 4 --cores "$(nproc)" --out-link build/nix-prefixed

env XDG_CACHE_HOME="$(pwd)/build/cache-prefixed" \
    ./build/nix-prefixed/bin/nix build '.#layer' \
    --extra-experimental-features nix-command --extra-experimental-features flakes \
    --option build-use-substitutes false --max-jobs 4 --cores "$(nproc)" \
    --out-link build/layer.zip
