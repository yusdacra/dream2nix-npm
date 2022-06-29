{
  description = "crates.io indexed & translated into dream2nix lockfile.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    dream2nix = {
      url = "github:nix-community/dream2nix/feat/indexers";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ilib = {
      url = "github:yusdacra/dream2nix-index-lib/feat/d2n-apps";
      inputs.dream2nix.follows = "dream2nix";
    };
  };

  outputs = inp:
    inp.ilib.lib.makeOutputsForIndexes {
      source = ./.;
      indexesForSystems = {
        "x86_64-linux" = ["npm"];
      };
      extendOutputs = {
        system,
        mkIndexApp,
        ...
      }: prev: {
        apps.${system} =
          prev.apps.${system}
          // {
            index-npm-top-250-binary = mkIndexApp {
              name = "npm";
              input = {
                queryText = "keywords:bin";
                maxPackageCount = 250;
              };
            };
          };
      };
    };
}
