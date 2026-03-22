{ stdenv, symlinkJoin, magnum, magnum-integration, magnum-plugins }:

symlinkJoin {
  name = "magnum-with-plugins";
  paths = [ magnum magnum-integration magnum-plugins ];
  meta = magnum.meta // {
    description = "Magnum with all selected plugins, libraries symlinked together (using symlinkJoin)";
  };
}
