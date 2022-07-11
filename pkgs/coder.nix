/* copy from nixpkgs but updated to fix arm64 support */
{ lib, stdenv, autoPatchelfHook, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "coder";
  version = "0.8.5";

  src = fetchurl {
    url = "github.com/coder/coder/releases/download/v${version}/coder_${version}_linux_arm64.tar.gz";
    sha256 = "sha256-7ymGVgoYzdWCnoJF3QjzfCpCeSVnbcyJ/gD/1HoAN+k=";
  };


  sourceRoot = ".";

  nativeBuildInputs = [ unzip ] ++ (if stdenv.isLinux then [
    # On Linux we need to do this so executables work
    autoPatchelfHook
  ] else [ ]);

  installPhase = ''
    mkdir -p $out/bin
    mv ${pname} $out/bin
  '';

  meta = with lib; {
    description = "Coder";
    homepage = "https://coder.com/";
    downloadPage = "https://coder.com/docs/coder-oss/latest/install";
    maintainers = with maintainers; [ joelburget marsam ];
    license = licenses.unfree;
    platforms = [ "i686-linux" "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
  };
}

