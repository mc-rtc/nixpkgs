{
  stdenv,
  lib,
  fetchgit,
  cmake,
  mc-rtc,
  politopix,
  jrl-cmakemodules,
  useLocal ? false,
  localWorkspace ? null,
}:

stdenv.mkDerivation (_finalAttrs: {
  pname = "mc-dynamic-polytopes";
  version = "1.0.1";

  src =
    if useLocal then
      builtins.trace
        "Using local workspace for mc-dynamic-polytopes: ${localWorkspace}/mc_dynamic_polytopes"
        (
          builtins.path {
            path = "${localWorkspace}/mc_dynamic_polytopes";
            name = "mc-dynamic-polytopes-src";
          }
        )
    else
      # FIXME: The release archive is missing jrl-cmakemodules, we should use v2 anyways
      # fetchFromGitHub {
      #   owner = "Hugo-L3174";
      #   repo = "mc_dynamic_polytopes";
      #   tag = "v${finalAttrs.version}";
      #   hash = "sha256-sexHwNWgviBlh3dKY1ssCdCriWoQH9q9xI5nEWuADIY=";
      # };
      # fetchgit {
      #   url = "https://github.com/Hugo-L3174/mc_dynamic_polytopes.git";
      #   rev = "v${finalAttrs.version}"; # or a commit hash or branch name
      #   hash = "sha256-sexHwNWgviBlh3dKY1ssCdCriWoQH9q9xI5nEWuADIY=";
      #   fetchSubmodules = false; # if the repository has submodules
      # };
      # https://github.com/Hugo-L3174/mc_dynamic_polytopes/pull/6 future v1.0.1
      fetchgit {
        url = "https://github.com/Hugo-L3174/mc_dynamic_polytopes.git";
        # PR#6
        rev = "35b98db7feb8d10e95737c419ec54ea30ef9780a"; # or a commit hash or branch name
        hash = "";
      };

  nativeBuildInputs = [
    cmake
    jrl-cmakemodules
  ];
  propagatedBuildInputs = [
    mc-rtc
    politopix
  ];

  cmakeFlags = [
    "-DMC_RTC_HONOR_INSTALL_PREFIX=ON"
  ];

  doCheck = false;

  meta = with lib; {
    description = "mc_rtc library for dynamic balance polytopes computations using politopix";
    homepage = "https://github.com/Hugo-L3174/mc_dynamic_polytopes";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
})
