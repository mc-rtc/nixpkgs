{ stdenv, lib, fetchurl, fetchFromGitHub,
cmake, boost,
useLocal ? false, localWorkspace ? null
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "politopix";
  version = "1.0.0";

  src = if useLocal then
      builtins.trace "Using local workspace for politopix: ${localWorkspace}/politopix"
      (builtins.path {
        path = "${localWorkspace}/politopix";
        name = "politopix-src";
      })
    else
      # fetchFromGitHub {
      #   owner = "Hugo-L3174";
      #   repo = "politopix";
      #   tag = "v${finalAttrs.version}";
      #   hash = "";
      # };

      # XXX: this is built from a private github repository
      # TODO: provide documentation
      # To make it work we need to setup a netrc file in /etc/nix/netrc and configure nix
      # sandbox to use it
      # see: https://nixos.wiki/wiki/Enterprise and https://discourse.nixos.org/t/how-to-fetchurl-with-credentials/11994/5
      # and my own nixos configuration here: https://github.com/arntanguy/nixos-dotfiles/commit/9ae45cb3cd73b0428382e64641b1345565fdeb12
      fetchurl {
        url = "https://github.com/Hugo-L3174/politopix/archive/refs/tags/v${finalAttrs.version}.tar.gz";
        # To get the hash:
        # - download release from github
        # - nix hash file <release>.tar.gz
        sha256 = "sha256-xAlIXz3yviOKN0AjF2kGP06TJ4HEymMNdjbRdOkbi6I=";
      };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ boost ];

  cmakeFlags = [
    "-DCMAKE_CXX_FLAGS=-DBOOST_TIMER_ENABLE_DEPRECATED"
  ];

  doCheck = false;

  meta = with lib; {
    description = " Github port of I2S Bordeaux's politopix library ";
    homepage    = "https://github.com/Hugo-L3174/politopix";
    license     = lib.licenses.gpl3Plus;
    platforms   = platforms.all;
  };
})
