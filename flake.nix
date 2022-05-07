{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    dream2nix = {
      url = "github:nix-community/dream2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ilib = {
      url = "github:yusdacra/dream2nix-index-lib";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.dream2nix.follows = "dream2nix";
    };
  };

  outputs = {dream2nix, ...} @ inputs: let
    l = inputs.nixpkgs.lib // builtins;

    systems = ["x86_64-linux"];

    mkOutputsForSystem = system: let
      ilib = inputs.ilib.lib.mkLib {
        inherit system;
        subsystem = "nodejs";
        fetcherName = "npm";
        translatorName = "package-lock";
      };
    in {
      lib.${system} = {inherit ilib;};
    };
  in
    l.foldl'
    l.recursiveUpdate
    {}
    (l.map mkOutputsForSystem systems);
}
