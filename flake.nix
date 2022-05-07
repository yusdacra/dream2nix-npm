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
        translatorForPath = {
          "package-lock.json" = "package-lock";
          "yarn.lock" = "yarn-lock";
          __default = "package-json";
        };
      };
      pkgs = inputs.nixpkgs.legacyPackages.${system};

      genTree = dream2nix.lib.dlib.prepareSourceTree {source = ./gen;};
      index = genTree.files."index.json".jsonContent;

      translateScript = let
        pkgsUnflattened =
          l.mapAttrsToList
          (
            name: versions:
              l.mapAttrsToList
              (
                version: hash:
                  {inherit name version;}
                  // (l.optionalAttrs (hash != null) {inherit hash;})
              )
              versions
          )
          index;
      in
        ilib.translateBin (l.flatten pkgsUnflattened);

      indexer = with pkgs;
        writeScript
        "indexer.sh"
        ''
          #!${stdenv.shell}
          url="https://registry.npmjs.org/-/v1/search?text=$1&popularity=1.0&quality=0.0&maintenance=0.0&size=250"
          ${curl}/bin/curl -k "$url" \
            | ${jq}/bin/jq '[.objects[].package | {(.name): {(.version): null}}] | add' -r
        '';
      indexScript = with pkgs;
        writeScript
        "index.sh"
        ''
          #!${stdenv.shell}
          ${indexer} "keywords:bin" > gen/index.json
        '';

      lockOutputs = ilib.mkLocksOutputs {tree = genTree;};
    in {
      packages.${system} = lockOutputs;
      apps.${system} = {
        translate = {
          type = "app";
          program = toString translateScript;
        };
        index = {
          type = "app";
          program = toString indexScript;
        };
      };
      lib.${system} = {inherit ilib translateScript;};
    };
  in
    l.foldl'
    l.recursiveUpdate
    {}
    (l.map mkOutputsForSystem systems);
}
