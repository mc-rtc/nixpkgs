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

  src = fetchFromGitHub {
    owner = "mosra";
    repo = "magnum";
    rev = "369e9620ab22224ae66a376290b9b36e872209ce";
    hash = "sha256-ld8liF60ImYVNr4qEbcacu/8wtaC7jZEzpamKW380TU=";
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
