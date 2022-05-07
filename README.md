# dream2nix-npm

npm indexed and translated into dream2nix lockfiles.
The package index & lock files are updated automatically every day (at 06:00 UTC).

### Usage

The generated packages are available under the `packages` output of the flake.

### Generating lock files

1. index with `nix run .#index`
2. translate with `nix run .#translate`