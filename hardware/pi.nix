# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    "${builtins.fetchTarball {
      url = "https://github.com/NixOS/nixos-hardware/archive/936e4649098d6a5e0762058cb7687be1b2d90550.tar.gz";
      sha256 = "";
      }
    }/raspberry-pi/4"
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "uhci_hcd" "virtio_pci" "usbhid" "usb_storage" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];


  # Enable GPU acceleration
  hardware.raspberry-pi."4".fkms-3d.enable = true;
  hardware.bluetooth.enable = true;
  hardware.pulseaudio.enable = true;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  swapDevices = [ ];
}
