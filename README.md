Some usage notes:
* Modify the `paths` argument used to create `layer-contents` to change what's in the layer zip.
* A symlink to the combined `bin` is placed at `/opt/bin`, which is part of Lambda's default `PATH`.
* Lambda sets `LD_LIBRARY_PATH`, which will make Nix binaries break. Unset it at runtime.
* `./build.sh` will bootstrap you so that you don't need a flake-compatible Nix to get started.
