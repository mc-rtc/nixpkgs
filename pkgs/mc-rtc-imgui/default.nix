{ stdenv, lib, fetchFromGitHub,
cmake, jrl-cmakemodules,
mc-rtc, imgui, implot
, useLocal ? false, localWorkspace ? null
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mc-rtc-imgui";
  version = "1.0.0";

  dontBuild = true;

  src = if useLocal then
      builtins.trace "Using local workspace for mc-rtc-imgui: ${localWorkspace}/mc_rtc-imgui"
      (builtins.path {
        path = "${localWorkspace}/mc_rtc-imgui";
        name = "mc-rtc-imgui-src";
      })
    else
      fetchFromGitHub {
        #owner = "mc-rtc";
        owner = "arntanguy";
        repo = "mc_rtc-imgui";
        # tag = "v${finalAttrs.version}";
        # future v1.0.0 release from nix-standalone
        # http://github.com/mc-rtc/mc_rtc-imgui/pull/25
        rev = "44a4e51586ea3308457205b2973023fbc2f95485";
        hash = "sha256-J1oitwCXhtDGLW0vCnAN50BkUQeveuuruLz1TCOYe2Q=";
      };

  nativeBuildInputs = [ cmake jrl-cmakemodules ];
  propagatedBuildInputs =
    [
      mc-rtc
      imgui
      implot
    ];

  cmakeFlags = [
    "-DMC_RTC_HONOR_INSTALL_PREFIX=ON"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Base GUI client for mc_rtc using Dear ImGui";
    homepage    = "https://github.com/mc-rtc/mc_rtc-imgui";
    license     = licenses.bsd2; # FIXME set licence in repository
    platforms   = platforms.all;
  };
})
