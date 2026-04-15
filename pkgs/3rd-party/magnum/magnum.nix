# filepath: pkgs/3rd-party/magnum/magnum.nix
{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  corrade,
  libGL,
  libX11,
  openal,
  glfw,
  SDL2,
  useLocal ? false,
  localWorkspace ? null,
  magnumWithGlfwApplication ? true,
  magnumWithSDL2Application ? true,
  magnumWithAnyImageImporter ? true,
  magnumWithAnySceneImporter ? true,
  magnumWithObjImporter ? true,
  magnumWithAssimpImporter ? true,
  magnumWithStbImageImporter ? false,
}:

stdenv.mkDerivation (_finalAttrs: {
  pname = "magnum";
  version = "0.0.0";

  dontBuild = true;

  src =
    if useLocal then
      builtins.trace "Using local workspace for magnum: ${localWorkspace}/magnum" (
        builtins.path {
          path = "${localWorkspace}/magnum-standalone";
          name = "magnum-src";
        }
      )
    else
      fetchFromGitHub {
        owner = "mosra";
        repo = "magnum";
        # up-to-date
        rev = "2a3acc0f22f42026c04553a73c1549e577c54e2f";
        hash = "sha256-C9WxwC02J21SMPR2wtVZfgFaCRuZceyIAEjg0oiWkH4=";
        # orginal from mc-rtc-magnum
        # rev = "440653dbb8815ba28fd20203acae711dbb8b14b4";
        # hash = "sha256-65Pa7NqUMHJX80oLoJ+WpB9tj00XQSFjJIuBahrlZtg=";
      };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    corrade
    libGL
    openal
    glfw
  ]
  ++ lib.optionals magnumWithGlfwApplication [ libX11 ]
  ++ lib.optionals magnumWithSDL2Application [ SDL2 ];
  # propagatedBuildInputs = finalAttrs.buildInputs;

  cmakeFlags = [
    "-DMAGNUM_WITH_GLFWAPPLICATION=${if magnumWithGlfwApplication then "ON" else "OFF"}"
    "-DMAGNUM_WITH_SDL2APPLICATION=${if magnumWithGlfwApplication then "ON" else "OFF"}"
    "-DMAGNUM_WITH_ANYIMAGEIMPORTER=${if magnumWithAnyImageImporter then "ON" else "OFF"}"
    "-DMAGNUM_WITH_ANYSCENEIMPORTER=${if magnumWithAnySceneImporter then "ON" else "OFF"}"
    "-DMAGNUM_WITH_OBJIMPORTER=${if magnumWithObjImporter then "ON" else "OFF"}"
    "-DMAGNUM_WITH_ASSIMPIMPORTER=${if magnumWithAssimpImporter then "ON" else "OFF"}"
    "-DMAGNUM_WITH_STBIMAGEIMPORTER=${if magnumWithStbImageImporter then "ON" else "OFF"}"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Lightweight and modular C++11 graphics middleware for games and data visualization ";
    homepage = "https://github.com/msora/magnum";
    license = licenses.bsd2; # FIXME
    platforms = platforms.all;
  };
})
