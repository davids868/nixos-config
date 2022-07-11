# { stdenv, buildGoModule, fetchFromGitHub, lib, ... }:
#
# buildGoModule rec {
#   pname = "tt";
#   version = "0.4.2";
#
#   src = fetchFromGitHub {
#     owner = "lemnos";
#     repo = "tt";
#     rev = "v${version}";
#     sha256 = "sha256-vKh19xYBeNqvVFilvA7NeQ34RM5VnwDs+Hu/pe3J0y4=";
#   };
#
#   vendorSha256 = "sha256-edY2CcZXOIed0+7IA8kr4lAfuSJx/nHtmc734XzT4z4=";
#
#   meta = with lib; {
#     description = "A terminal based typing test.";
#     homepage = "https://github.com/lemnos/tt";
#     license = licenses.mit;
#     maintainers = with maintainers; [ lemnos ];
#     platforms = platforms.linux ++ platforms.darwin;
#   };
# }

/* copy from nixpkgs but updated to fix arm64 support */
{ lib, stdenv, autoPatchelfHook, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "tt";
  version = "0.4.2";

  src = fetchurl {
    url = "github.com/lemnos/tt/releases/download/v${version}/tt-linux_arm64";
    sha256 = "sha256-3/0WuQa3p5KVbu6rlxv96H6YruENiS4EaoRFRm31uXg=";
  };


  sourceRoot = ".";
  phases = [ "installPhase" ];

  # nativeBuildInputs = [ unzip ] ++ (if stdenv.isLinux then [
  #   # On Linux we need to do this so executables work
  #   autoPatchelfHook
  # ] else [ ]);

  installPhase = ''
    mkdir -p $out/bin
    mv tt $out/bin/${pname}
  '';

  meta = with lib; {
    description = "A terminal based typing test.";
    homepage = "https://github.com/lemnos/tt";
    license = licenses.mit;
    maintainers = with maintainers; [ lemnos ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}


