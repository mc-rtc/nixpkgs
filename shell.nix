{ pkgs ? import <nixpkgs> { overlays = [ (import ./default.nix) ]; }
}:
pkgs.mkShell {
  buildInputs = with pkgs; [ cmake hpp-spline tasks mc-rtc-data ];
}
