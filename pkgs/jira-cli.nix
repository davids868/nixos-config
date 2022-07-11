/* copy from nixpkgs but updated to fix arm64 support */
{ lib, stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "jira-cli";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "ankitpokhrel";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-+WkeiB4vgKxlVNnd5cEMmE9EYcGAqrzIrLsvPAA1eOE=";
  };

  vendorSha256 = "sha256-SpUggA9u8OGV2zF3EQ0CB8M6jpiVQi957UGaN+foEuk=";

  meta = with lib; {
    description = "Jira-cli";
    homepage = "https://github.com/ankitpokhrel/jira-cli";
    downloadPage = "https://github.com/ankitpokhrel/jira-cli/releases";
    maintainers = with maintainers; [ ankitpokhrel ];
    license = licenses.unfree;
    platforms = [ "i686-linux" "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
  };
}

