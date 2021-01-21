self: super:
{
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
}
