{
  stdenv,
  lib,
  fetchFromGitHub,
  symlinkJoin,
  cmake,
  corrade,
  libGL,
  libX11,
  openal,
  glfw,
  SDL2,
  magnumWithAudio ? true,
  magnumWithGlfwApplication ? true,
  magnumWithSDL2Application ? true,
  magnumWithAnyImageImporter ? true,
  magnumWithAnySceneImporter ? true,
  magnumWithObjImporter ? true,
  magnumWithAssimpImporter ? true,
  magnumWithStbImageImporter ? false,
  magnumWithGlxApplication ? true,
  magnumWithWindowlessGlxApplication ? true,
  magnumBuildDeprecated ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "magnum";
  version = "2020.06-unstable-2026-10-19";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "mosra";
    repo = "magnum";
    rev = "369e9620ab22224ae66a376290b9b36e872209ce";
    hash = "sha256-ld8liF60ImYVNr4qEbcacu/8wtaC7jZEzpamKW380TU=";
  };

  nativeBuildInputs = [
    cmake
    corrade # Makes corrade-rc accessible during build
  ];
  propagatedBuildInputs = [
    corrade
    libGL
    openal
    glfw
  ]
  ++ lib.optionals magnumWithGlfwApplication [ libX11 ]
  ++ lib.optionals magnumWithSDL2Application [ SDL2 ];

  cmakeFlags = [
    (lib.cmakeBool "MAGNUM_BUILD_TESTS" true)
    (lib.cmakeBool "MAGNUM_BUILD_DEPRECATED" magnumBuildDeprecated)
    (lib.cmakeBool "MAGNUM_WITH_AUDIO" magnumWithAudio)
    (lib.cmakeBool "MAGNUM_WITH_GLFWAPPLICATION" magnumWithGlfwApplication)
    (lib.cmakeBool "MAGNUM_WITH_GLXAPPLICATION" magnumWithGlxApplication)
    (lib.cmakeBool "MAGNUM_WITH_WINDOWLESSGLXAPPLICATION" magnumWithWindowlessGlxApplication)
    (lib.cmakeBool "MAGNUM_WITH_SDL2APPLICATION" magnumWithGlfwApplication)
    (lib.cmakeBool "MAGNUM_WITH_ANYIMAGEIMPORTER" magnumWithAnyImageImporter)
    (lib.cmakeBool "MAGNUM_WITH_ANYSCENEIMPORTER" magnumWithAnySceneImporter)
    (lib.cmakeBool "MAGNUM_WITH_OBJIMPORTER" magnumWithObjImporter)
    (lib.cmakeBool "MAGNUM_WITH_ASSIMPIMPORTER" magnumWithAssimpImporter)
    (lib.cmakeBool "MAGNUM_WITH_STBIMAGEIMPORTER" magnumWithStbImageImporter)
  ];

  doCheck = true;
  preCheck = ''
    # Needed for unit tests trying to use Alsa, which is not available in the sandbox
    export ALSOFT_DRIVERS=null
  '';

  passthru = {
    inherit magnumBuildDeprecated;
    withPlugins =
      extensions:
      symlinkJoin {
        name = "${finalAttrs.pname}-with-plugins-${finalAttrs.version}";
        paths = [
          finalAttrs.finalPackage
        ]
        ++ extensions;
      };
  };

  meta = with lib; {
    description = "Lightweight and modular C++11 graphics middleware for games and data visualization ";
    homepage = "https://github.com/msora/magnum";
    license = licenses.mit;
    maintainers = with maintainers; [ arntanguy ];
    platforms = platforms.all;
  };
})
