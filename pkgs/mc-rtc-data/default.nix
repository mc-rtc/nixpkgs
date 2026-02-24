{ stdenv
, lib
, with-ros ? false
, buildRosPackage
, ament-cmake
, mc-env-description
, mc-int-obj-description
, jvrc-description
, writeTextFile
, runCommand
}:

let
  version = "1.0.8";
  pname = "mc-rtc-data";

  deps = [
    { name = "mc_env_description"; drv = mc-env-description; }
    { name = "mc_int_obj_description"; drv = mc-int-obj-description; }
    { name = "jvrc_description"; drv = jvrc-description; }
  ];

  execDependsXml = lib.concatMapStrings (d: "<exec_depend>${d.name}</exec_depend>\n") deps;

  packageXml = writeTextFile {
    name = "package.xml";
    text = ''
      <package format="3">
        <name>${pname}</name>
        <version>${version}</version>
        <description>Metapackage for mc-rtc data</description>
        <maintainer email="your@email.com">Your Name</maintainer>
        <license>BSD-2-Clause</license>
        <buildtool_depend>ament_cmake</buildtool_depend>
        ${execDependsXml}
        <export>
          <metapackage/>
        </export>
      </package>
    '';
  };

  cmakeLists = writeTextFile {
    name = "CMakeLists.txt";
    text = ''
      cmake_minimum_required(VERSION 3.5)
      project(${pname})
      find_package(ament_cmake REQUIRED)
      ament_package()
    '';
  };

  metaSrc = runCommand "mc-rtc-data-meta" { } ''
    mkdir -p $out
    cp ${packageXml} $out/package.xml
    cp ${cmakeLists} $out/CMakeLists.txt
  '';

  propagatedBuildInputs = map (d: d.drv) deps;

in

if with-ros then
  buildRosPackage {
    inherit pname version;
    src = metaSrc;
    inherit propagatedBuildInputs;
    buildType = "ament_cmake";
    nativeBuildInputs = [ ament-cmake ];
    meta = with lib; {
      description = "Metapackage for mc-rtc data (envs, objects, etc)";
      homepage    = "https://github.com/jrl-umi3218/mc_rtc_data";
      license     = licenses.bsd2;
      platforms   = platforms.all;
    };
  }
else
  stdenv.mkDerivation {
    inherit pname version;
    src = null;
    propagatedBuildInputs = map (d: d.drv) deps;
    buildInputs = [];
    nativeBuildInputs = [ ];
    installPhase = ''
      mkdir -p $out
    '';
    meta = with lib; {
      description = "Metapackage for mc-rtc data (envs, objects, etc)";
      homepage    = "https://github.com/jrl-umi3218/mc_rtc_data";
      license     = licenses.bsd2;
      platforms   = platforms.all;
    };
  }
