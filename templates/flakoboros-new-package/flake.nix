{
  description = "CHANGEME";

  inputs.mc-rtc-nix.url = "github:mc-rtc/nixpkgs";

  outputs =
    inputs:
    inputs.mc-rtc-nix.lib.mkFlakoboros inputs (
      { ... }:
      {
        packages = {
          CHANGEME =
            { stdenv, ... }:
            stdenv.mkDerivation {
              name = "CHANGEME";
              src = ./.;
              buildInputs = [ ];
              buildPhase = ''
                echo "Building CHANGEME"
              '';
              shellHook = ''
                echo "Hello from CHANGEME"
              '';
              installPhase = ''
                mkdir -p $out/bin
                echo "Installing CHANGEME"
                echo "#!/bin/sh" > $out/bin/CHANGEME
                echo "echo 'Hello from CHANGEME'" >> $out/bin/CHANGEME
                chmod +x $out/bin/CHANGEME
              '';
            };
        };
      }
    );
}
