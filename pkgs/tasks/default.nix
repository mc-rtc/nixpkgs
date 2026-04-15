{
  stdenv,
  lib,
  cmake,
  rbdyn,
  sch-core,
  eigen-qld,
}:

stdenv.mkDerivation rec {
  pname = "tasks";
  version = "v1.8.2";

  src = fetchTarball {
    url = "https://github.com/jrl-umi3218/Tasks/releases/download/${version}/Tasks-${version}.tar.gz";
    sha256 = "0if144c0jjpxk97fn2qszybdlx8b66qsa1kdkvwzfipvf8fh364q";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    rbdyn
    sch-core
    eigen-qld
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  postPatch = ''
    # Remove the include from the main CMakeLists.txt
    sed -i '/include(cmake\/cython\/cython.cmake)/d' CMakeLists.txt

    # Add the include to the top of the python binding CMakeLists.txt
    sed -i '1i include(cmake/cython/cython.cmake)' binding/python/CMakeLists.txt
  '';

  doCheck = true;

  meta = with lib; {
    description = "Real-time control for kinematics tree and list of kinematics tree";
    homepage = "https://github.com/jrl-umi3218/tasks";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
