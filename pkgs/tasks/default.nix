{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  jrl-cmakemodules,
  rbdyn,
  sch-core,
  eigen-qld,
  python3Packages,
  with-lssol ? false,
  eigen-lssol ? null,
  with-python ? true,
}:

let
  use-python = with-python && !stdenv.hostPlatform.isDarwin;
in
stdenv.mkDerivation {
  pname = if (with-lssol && eigen-lssol != null) then "tasks-lssol" else "tasks-qld";
  version = "v1.8.4";

  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "Tasks";
    tag = "v1.8.4";
    hash = "sha256-1XrRagwiMJwukbqPmlJCzp/Y11POdUdDIFjeZTCg3Ik=";
  };

  buildInputs = [
    jrl-cmakemodules
  ];
  nativeBuildInputs = [
    cmake
  ]
  ++ lib.optionals use-python [
    python3Packages.distutils
    python3Packages.pytest
    python3Packages.cython
    python3Packages.python
  ];

  propagatedBuildInputs = [
    rbdyn
    sch-core
    eigen-qld
  ]
  ++ lib.optional (with-lssol && eigen-lssol != null) eigen-lssol
  ++ lib.optionals use-python [
    python3Packages.rbdyn
    python3Packages.sch-core-python
  ];

  cmakeFlags = [
    (lib.cmakeBool "PYTHON_BINDING" use-python)
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  # XXX: Without this fixupPhase fails due to RPATHS references to /build/
  preFixup = lib.optionalString use-python ''
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
