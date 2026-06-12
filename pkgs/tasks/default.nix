{
  stdenv,
  lib,
  cmake,
  jrl-cmakemodules,
  rbdyn,
  sch-core,
  eigen-qld,
  python3Packages,
  with-lssol ? false,
  eigen-lssol ? null,
}:

stdenv.mkDerivation rec {
  pname = if (with-lssol && eigen-lssol != null) then "tasks-lssol" else "tasks-qld";
  version = "v1.8.2";

  src = fetchTarball {
    url = "https://github.com/jrl-umi3218/Tasks/releases/download/${version}/Tasks-${version}.tar.gz";
    sha256 = "0if144c0jjpxk97fn2qszybdlx8b66qsa1kdkvwzfipvf8fh364q";
  };

  nativeBuildInputs = [
    cmake
    jrl-cmakemodules
    python3Packages.distutils
    python3Packages.pytest
    python3Packages.cython
    python3Packages.python
  ];
  propagatedBuildInputs = [
    rbdyn
    sch-core
    eigen-qld
    python3Packages.rbdyn
    python3Packages.sch-core-python
  ]
  ++ lib.optional (with-lssol && eigen-lssol != null) eigen-lssol;

  cmakeFlags = [
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  # XXX: Without this fixupPhase fails due to RPATHS references to /build/
  preFixup = ''
    patchelf --shrink-rpath --allowed-rpath-prefixes "$NIX_STORE" $out/${python3Packages.python.sitePackages}/tasks/tasks.so
    patchelf --shrink-rpath --allowed-rpath-prefixes "$NIX_STORE" $out/${python3Packages.python.sitePackages}/tasks/qp/qp.so
  '';

  doCheck = true;

  meta = with lib; {
    description = "Real-time control for kinematics tree and list of kinematics tree";
    homepage = "https://github.com/jrl-umi3218/tasks";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
