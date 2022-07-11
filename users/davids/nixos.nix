{ pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/pull/2408
  environment.pathsToLink = [ "/share/fish" ];

  users.users.davids = {
    isNormalUser = true;
    home = "/home/davids";
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.fish;
    password = " ";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICykuWv5M+ebvVBmFjYNb9+94zXq4J2iPpiTw49RbYm0 david.sapiro@gmail.com"
    ];
  };

  nixpkgs.overlays = import ../../lib/overlays.nix ++ [
    (import ./vim.nix)
  ];
}
