{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  magnum,
  imgui,
  useLocal ? false,
  localWorkspace ? null,
  with-imguiintegration ? false,
}:

# option(MAGNUM_WITH_BULLETINTEGRATION "Build BulletIntegration library" OFF)
# option(MAGNUM_WITH_DARTINTEGRATION "Build DartIntegration library" OFF)
# option(MAGNUM_WITH_EIGENINTEGRATION "Build EigenIntegration library" OFF)
# option(MAGNUM_WITH_GLMINTEGRATION "Build GlmIntegration library" OFF)
# option(MAGNUM_WITH_IMGUIINTEGRATION "Build ImGuiIntegration library" OFF)
# option(MAGNUM_WITH_OVRINTEGRATION "Build OvrIntegration library" OFF)
# option(MAGNUM_WITH_YOGAINTEGRATION "Build YogaIntegration library" OFF)

stdenv.mkDerivation (_finalAttrs: {
  pname = "magnum-integration";
  version = "0.0.0";

  dontBuild = true;

  src =
    if useLocal then
      builtins.trace "Using local workspace for magnum-integration: ${localWorkspace}/magnum-integration"
        (
          builtins.path {
            path = "${localWorkspace}/magnum-integration";
            name = "magnum-integration-src";
          }
        )
    else
      fetchFromGitHub {
        owner = "mosra";
        repo = "magnum-integration";
        rev = "26a3af2d376b58ba82a0ab8314006d40d630ee73";
        hash = "sha256-JE+EaTLNxNi5E8Y1J6YBSB6OTadaRM4awpDntIkNfRU=";
      };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ magnum ] ++ lib.optional with-imguiintegration imgui;

  cmakeFlags = [ ] ++ lib.optional with-imguiintegration "-DMAGNUM_WITH_IMGUIINTEGRATION=ON";

  doCheck = false;

  meta = with lib; {
    description = "Integration libraries for the Magnum C++11 graphics engine";
    homepage = "https://github.com/msora/magnum-integration";
    license = licenses.bsd2; # FIXME
    platforms = platforms.all;
  };
})
