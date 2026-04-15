{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  magnum,
  useLocal ? false,
  localWorkspace ? null,
  assimp,
  libz,
  # tested
  magnumPluginsWithAssimpImporter ? true,
  magnumPluginsWithStbImageImporter ? true,
  # untested
  magnumPluginsWithBasisImageConverter ? false,
  magnumPluginsWithBasisImporter ? false,
  magnumPluginsWithCgltfImporter ? false,
  magnumPluginsWithDrFlacAudioImporter ? false,
  magnumPluginsWithDrMp3AudioImporter ? false,
  magnumPluginsWithDrWavAudioImporter ? false,
  magnumPluginsWithFaad2AudioImporter ? false,
  magnumPluginsWithFreetypeFont ? false,
  magnumPluginsWithHarfBuzzFont ? false,
  magnumPluginsWithIcoImporter ? false,
  magnumPluginsWithJpegImageConverter ? false,
  magnumPluginsWithJpegImporter ? false,
  magnumPluginsWithKtxImageConverter ? false,
  magnumPluginsWithKtxImporter ? false,
  magnumPluginsWithMeshOptimizer ? false,
  magnumPluginsWithMiniExrImageConverter ? false,
  magnumPluginsWithOpenDdl ? false,
  magnumPluginsWithOpenGexImporter ? false,
  magnumPluginsWithPngImageConverter ? false,
  magnumPluginsWithPngImporter ? false,
  magnumPluginsWithPrimitiveImporter ? false,
  magnumPluginsWithStanfordImporter ? false,
  magnumPluginsWithStbImageConverter ? false,
  magnumPluginsWithStbVorbisAudioImporter ? false,
  magnumPluginsWithTinyGltfImporter ? false,
  magnumPluginsWithUvImageConverter ? false,
}:

stdenv.mkDerivation (_finalAttrs: {
  pname = "magnum-plugins";
  version = "0.0.0";

  dontBuild = true;

  src =
    if useLocal then
      builtins.trace "Using local workspace for magnum-plugins: ${localWorkspace}/magnum-plugins" (
        builtins.path {
          path = "${localWorkspace}/magnum-plugins";
          name = "magnum-plugins-src";
        }
      )
    else
      fetchFromGitHub {
        owner = "mosra";
        repo = "magnum-plugins";
        rev = "32e3270380ed9b261f0c03459d3c57ba485a461b";
        hash = "sha256-lAj7XtapGKF4EVv57KNzU+WV9D0IqxbsBtJrU6fn9II=";
      };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    magnum
  ]
  ++ lib.optionals magnumPluginsWithAssimpImporter [
    assimp
    libz
  ];

  cmakeFlags = [
    "-DMAGNUM_WITH_ASSIMPIMPORTER=${if magnumPluginsWithAssimpImporter then "ON" else "OFF"}"
    "-DMAGNUM_WITH_BASISIMAGECONVERTER=${if magnumPluginsWithBasisImageConverter then "ON" else "OFF"}"
    "-DMAGNUM_WITH_BASISIMPORTER=${if magnumPluginsWithBasisImporter then "ON" else "OFF"}"
    "-DMAGNUM_WITH_CGLTFIMPORTER=${if magnumPluginsWithCgltfImporter then "ON" else "OFF"}"
    "-DMAGNUM_WITH_DRFLACAUDIOIMPORTER=${if magnumPluginsWithDrFlacAudioImporter then "ON" else "OFF"}"
    "-DMAGNUM_WITH_DRMP3AUDIOIMPORTER=${if magnumPluginsWithDrMp3AudioImporter then "ON" else "OFF"}"
    "-DMAGNUM_WITH_DRWAVAUDIOIMPORTER=${if magnumPluginsWithDrWavAudioImporter then "ON" else "OFF"}"
    "-DMAGNUM_WITH_FAAD2AUDIOIMPORTER=${if magnumPluginsWithFaad2AudioImporter then "ON" else "OFF"}"
    "-DMAGNUM_WITH_FREETYPEFONT=${if magnumPluginsWithFreetypeFont then "ON" else "OFF"}"
    "-DMAGNUM_WITH_HARFBUZZFONT=${if magnumPluginsWithHarfBuzzFont then "ON" else "OFF"}"
    "-DMAGNUM_WITH_ICOIMPORTER=${if magnumPluginsWithIcoImporter then "ON" else "OFF"}"
    "-DMAGNUM_WITH_JPEGIMAGECONVERTER=${if magnumPluginsWithJpegImageConverter then "ON" else "OFF"}"
    "-DMAGNUM_WITH_JPEGIMPORTER=${if magnumPluginsWithJpegImporter then "ON" else "OFF"}"
    "-DMAGNUM_WITH_KTXIMAGECONVERTER=${if magnumPluginsWithKtxImageConverter then "ON" else "OFF"}"
    "-DMAGNUM_WITH_KTXIMPORTER=${if magnumPluginsWithKtxImporter then "ON" else "OFF"}"
    "-DMAGNUM_WITH_MESHOPTIMIZER=${if magnumPluginsWithMeshOptimizer then "ON" else "OFF"}"
    "-DMAGNUM_WITH_MINIEXRIMAGECONVERTER=${
      if magnumPluginsWithMiniExrImageConverter then "ON" else "OFF"
    }"
    "-DMAGNUM_WITH_OPENDDL=${if magnumPluginsWithOpenDdl then "ON" else "OFF"}"
    "-DMAGNUM_WITH_OPENGEXIMPORTER=${if magnumPluginsWithOpenGexImporter then "ON" else "OFF"}"
    "-DMAGNUM_WITH_PNGIMAGECONVERTER=${if magnumPluginsWithPngImageConverter then "ON" else "OFF"}"
    "-DMAGNUM_WITH_PNGIMPORTER=${if magnumPluginsWithPngImporter then "ON" else "OFF"}"
    "-DMAGNUM_WITH_PRIMITIVEIMPORTER=${if magnumPluginsWithPrimitiveImporter then "ON" else "OFF"}"
    "-DMAGNUM_WITH_STANFORDIMPORTER=${if magnumPluginsWithStanfordImporter then "ON" else "OFF"}"
    "-DMAGNUM_WITH_STBIMAGECONVERTER=${if magnumPluginsWithStbImageConverter then "ON" else "OFF"}"
    "-DMAGNUM_WITH_STBIMAGEIMPORTER=${if magnumPluginsWithStbImageImporter then "ON" else "OFF"}"
    "-DMAGNUM_WITH_STBVORBISAUDIOIMPORTER=${
      if magnumPluginsWithStbVorbisAudioImporter then "ON" else "OFF"
    }"
    "-DMAGNUM_WITH_TINYGLTFIMPORTER=${if magnumPluginsWithTinyGltfImporter then "ON" else "OFF"}"
    "-DMAGNUM_WITH_UVIMAGECONVERTER=${if magnumPluginsWithUvImageConverter then "ON" else "OFF"}"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Plugins for the Magnum C++11 graphics engine";
    homepage = "https://github.com/msora/magnum-plugins";
    license = licenses.bsd2; # FIXME
    platforms = platforms.all;
  };
})
