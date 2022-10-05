{ pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/pull/2408
  environment.pathsToLink = [ "/share/fish" ];

  users.users.davids = {
    isNormalUser = true;
    home = "/home/davids";
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.fish;
    hashedPassword = "$6$QvQojnKFBJ2v5fm/$jbeE83Ap8Ky6N8n/3ZiFC7UBb7vHpcsPNGvVyhRV.7XjJudL.E2zqzsZWYBFBvaeYiWD6NIny7DVJEz5KexHY1";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICykuWv5M+ebvVBmFjYNb9+94zXq4J2iPpiTw49RbYm0 david.sapiro@gmail.com"
    ];
  };

  nixpkgs.overlays = import ../../lib/overlays.nix ++ [
    (import ./vim.nix)
  ];
}
