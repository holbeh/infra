{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./wireguard.nix
    ./bbb.nix

    ../../common
  ];

  # vm connection
  services.qemuGuest.enable = true;

  boot.supportedFilesystems = [
    #"zfs"
    "vfat"
    "xfs"
  ];
  boot.loader.grub.device = "/dev/disk/by-path/pci-0000:00:0a.0";

  networking.hostName = "bbb-testing";
  networking.interfaces.ens18.useDHCP = true;
  networking.interfaces.ens18.tempAddress = "disabled";

  system.autoUpgrade.enable = true;
  nix.gc.automatic = true;

  systemd.services.nixos-upgrade.path = with pkgs; [
    gnutar
    xz.bin
    gzip
    config.nix.package.out
  ];

  fileSystems."/root/.gnupg" = {
    device = "/persist/data/gnupg-root";
    fsType = "none";
    options = [ "bind" ];
    neededForBoot = true;
  };

  fileSystems."/persist" = {
    neededForBoot = true;
  };

  system.stateVersion = "21.05";
}
