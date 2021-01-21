{ pkgs ? import <nixpkgs> { overlays = [ (import ./default.nix) ]; }
}:
pkgs.mkShell {
  buildInputs = with pkgs; [ cmake hpp-spline rbdyn eigen-qld eigen-quadprog ];
}
