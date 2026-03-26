{ stdenv, lib, fetchFromGitHub,
cmake, mc-rtc, eigen-quadprog, gram-savitzky-golay, jrl-cmakemodules,
useLocal ? false, localWorkspace ? null
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dcm-vrptask";
  version = "0.1.0";

  src = if useLocal then
      builtins.trace "Using local workspace for dcm-vrptask: ${localWorkspace}/DCM_VRPTask"
      (builtins.path {
        path = "${localWorkspace}/DCM_VRPTask";
        name = "dcm-vrptask-src";
      })
    else
      fetchFromGitHub {
        owner = "Hugo-L3174";
        repo = "DCM_VRPTask";
        #tag = "v${finalAttrs.version}";
        rev = "";
        hash = "";
      };

  nativeBuildInputs = [ cmake jrl-cmakemodules ];
  propagatedBuildInputs =
    [
      mc-rtc gram-savitzky-golay eigen-quadprog
    ];

  doCheck = false;

  meta = with lib; {
    description = "DCM-VRP tracking task for mc-rtc";
    homepage    = "https://github.com/Hugo-L3174/DCM_VRPTask";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
})
