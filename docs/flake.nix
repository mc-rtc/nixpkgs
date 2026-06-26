{
  description = "flake to generate docs";

  inputs = {
    mc-rtc-nix.url = "path:../";
    flakoboros.url = "github:Gepetto/flakoboros";

    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/develop";
    nixpkgs.follows = "nix-ros-overlay/nixpkgs";
    flake-parts.follows = "flakoboros/flake-parts";
    systems.follows = "flakoboros/systems";

    # search = {
    #   url = "github:NuschtOS/search";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      perSystem =
        {
          lib,
          pkgs,
          self',
          ...
        }:
        {
          devShells.default = pkgs.mkShell {
            name = "docs shell";
            packages = [
              pkgs.mdbook
              pkgs.nixdoc
            ];
          };

          packages = {
            default = pkgs.stdenvNoCC.mkDerivation {
              name = "mc-rtc-nix-docs-book";
              src = lib.cleanSource ./.;
              postPatch = ''
                substituteInPlace README.md --replace-warn "./docs/" "./"
              '';

              buildInputs = [
                self'.packages.gen-nixdoc
                # self'.packages.search
              ];
              nativeBuildInputs = [
                pkgs.mdbook
              ];

              buildPhase = ''
                cp -r ${self'.packages.gen-nixdoc}/* .

                mdbook build -d $out

                # mkdir -p $out/search
                # cp -r {self'.packages.search}/* $out/search
              '';
            };

            gen-nixdoc = pkgs.stdenvNoCC.mkDerivation {
              name = "mc-rtc-nix-docs-nixdoc";
              dontUnpack = true;
              nativeBuildInputs = [ pkgs.nixdoc ];

              buildPhase = ''
                mkdir $out
                nixdoc -p lib -c "" -d "Plain lib" -f ${inputs.mc-rtc-nix}/lib/default.nix > $out/plain-lib.md
                nixdoc -p libmc-rtc-nix -c "" -d "Generated lib" -f ${inputs.mc-rtc-nix}/lib/mk-lib.nix > $out/generated-lib.md
              '';
            };

            # search = inputs'.search.packages.mkSearch {
            #   baseHref = "/mc-rtc-nix/search/";
            #   modules = [ inputs.mc-rtc-nix.flakeModule ];
            #   title = "mc-rtc-nix";
            #   urlPrefix = "https://github.com/gepetto/mc-rtc-nix/blob/main/";
            # };
          };
        };
    };
}
