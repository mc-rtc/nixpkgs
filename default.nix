self: super:
{
  nanomsg = super.nanomsg.overrideAttrs( old : rec {
    postPatch = ''
      substituteInPlace cmake/nanomsg-config.cmake.in \
          --replace '@PACKAGE_CMAKE_INSTALL_PREFIX@/' ""
    '';
  });
  tinyxml-2 = super.tinyxml-2.overrideAttrs( old : rec {
    version = "8.0.0";
    src = super.fetchFromGitHub {
      repo = "tinyxml2";
      owner = "leethomason";
      rev = version;
      sha256 = "0raa8r2hsagk7gjlqjwax95ib8d47ba79n91r4aws2zg8y6ssv1d";
    };
  });
  hpp-spline = super.callPackage ./pkgs/hpp-spline {};
  spacevecalg = super.callPackage ./pkgs/spacevecalg {};
  rbdyn = super.callPackage ./pkgs/rbdyn {};
  eigen-qld = super.callPackage ./pkgs/eigen-qld {};
  eigen-quadprog = super.callPackage ./pkgs/eigen-quadprog {};
  sch-core = super.callPackage ./pkgs/sch-core {};
  tasks = super.callPackage ./pkgs/tasks {};
  mc-rtc-data = super.callPackage ./pkgs/mc-rtc-data {};
  state-observation = super.callPackage ./pkgs/state-observation {};
  mc-rbdyn-urdf = super.callPackage ./pkgs/mc-rbdyn-urdf {};
  mc-rtc = super.callPackage ./pkgs/mc-rtc {};
}
#          --replace 'include(@PACKAGE_CMAKE_INSTALL_PREFIX@/@PACKAGE_INSTALL_DESTINATION@/@PROJECT_NAME@-target.cmake)' 'include(\${CMAKE_CURRENT_LIST_DIR}/@PROJECT_NAME@-target.cmake)' \
