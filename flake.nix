{
  description = "crates.io indexed & translated into dream2nix lockfile.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    dream2nix = {
      url = "github:nix-community/dream2nix/feat/indexers";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inp:
    inp.dream2nix.lib.makeFlakeOutputsForIndexes {
      source = ./.;
      systems = ["x86_64-linux"];
      indexNames = ["npm"];
      overrideOutputs = {
        mkIndexApp,
        prevOutputs,
        ...
      }: {
        apps =
          prevOutputs.apps
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
