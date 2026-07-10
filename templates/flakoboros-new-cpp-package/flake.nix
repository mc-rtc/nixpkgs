{
  description = "cpp-template: getting started with C++, flakoboros and jrl-cmakemodules (v2)";

  inputs.mc-rtc-nix.url = "github:mc-rtc/nixpkgs";

  outputs =
    inputs:
    inputs.mc-rtc-nix.lib.mkFlakoboros inputs (
      { ... }:
      {
        packages = {
          cpp-template =
            {
              stdenv,
              eigen,
              cmake,
              jrl-cmakemodulesv2,
              catch2_3,
              ...
            }:
            stdenv.mkDerivation {
              name = "cpp-template";
              src = ./.;
              buildInputs = [
                catch2_3
                jrl-cmakemodulesv2
              ];
              nativeBuildInputs = [ cmake ];
              propagatedBuildInputs = [ eigen ];
              doCheck = true;
              shellHook = ''
                echo "Welcome to cpp-template."
                echo "Configure with: cmake -B build \$cmakeFlags"
                echo "Build with: cmake --build build"
                echo "Test with: ctest --test-dir build"
              '';
            };
        };
      }
    );
}
