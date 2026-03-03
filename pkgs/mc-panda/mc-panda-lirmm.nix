{ stdenv, lib, fetchgit, 
mc-panda,
cmake,
useLocal ? false, localWorkspace ? null
} :

let
  version = "1.0.0";
  localFolder = "mc_panda_lirmm";
in
stdenv.mkDerivation {
  pname = "mc-panda-lirmm";
  version = "${version}";

  src = if useLocal then
      builtins.trace "Using local workspace for mc-panda: ${localWorkspace}/${localFolder}"
      (builtins.path {
        path = "${localWorkspace}/${localFolder}";
        name = "mc-panda-lirmm-src";
      })
    else
      # TODO: release mc-panda-lirmm
      fetchgit {
        url = "https://github.com/arntanguy/mc_panda_lirmm";
        # topic/ConnectModules
        rev = "45be18e5eaffad2536bc46840d8c9b72770bb87e";
        sha256 = "sha256-+oepqf7i4rtAQZTXNDUo+QF1uw8Z2tEMdAy3Q94HJ1w=";
      };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ mc-panda ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
    "-DMC_RTC_HONOR_INSTALL_PREFIX=ON"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Panda RobotModule specialization for LIRMM robots for mc-rtc";
    homepage    = "https://github.com/jrl-umi3218/mc_panda_lirmm";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
