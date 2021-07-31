{ config, pkgs, lib, ... }:

{
  imports = [ ./kloenk.nix ./schluempfli.nix ];

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  nix.gc.automatic = lib.mkDefault true;
  nix.gc.options = lib.mkDefault "--delete-older-than 7d";
  nix.trustedUsers = [ "root" "@wheel" "kloenk" ];

  nix.registry.infra = {
    from.type = "indirect";
    from.id = "kloenk";
    to.type = "github";
    to.owner = "holbeh";
    to.repo = "infra";
    exact = false;
  };

  nix.systemFeatures = [ "recursive-nix" "kvm" "nixos-test" "big-parallel" ];
  nix.extraOptions = ''
    experimental-features = nix-command flakes ca-references recursive-nix progress-bar
  '';

  system.autoUpgrade.flake = "infra";

  networking.useDHCP = lib.mkDefault false;
  networking.useNetworkd = lib.mkDefault true;
  /* networking.search = [ "kloenk.de" ];
     networking.extraHosts = ''
       127.0.0.1 ${config.networking.hostName}.kloenk.de
     '';
  */

  networking.interfaces.lo = lib.mkDefault {
    ipv4.addresses = [
      {
        address = "127.0.0.1";
        prefixLength = 32;
      }
      {
        address = "127.0.0.53";
        prefixLength = 32;
      }
    ];
  };

  services.openssh = {
    enable = true;
    ports = [ 62954 ];
    passwordAuthentication = lib.mkDefault false;
    challengeResponseAuthentication = false;
    permitRootLogin = lib.mkDefault "prohibit-password";

    # extra config: StreamLocalBindUnlink yes
  };
  services.vnstat.enable = lib.mkDefault true;
  security.sudo.wheelNeedsPassword = false;

  petabyte.nftables.enable = true;
  petabyte.nftables.forwardPolicy = lib.mkDefault "drop";

  services.journald.extraConfig = "SystemMaxUse=2G";

  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  #console.keyMap = lib.mkDefault "neo";
  console.keyMap = lib.mkDefault "de";
  console.font = "Lat2-Terminus16";

  time.timeZone = "Europe/Berlin";

  environment.systemPackages = with pkgs; [
    #termite.terminfo
    rxvt_unicode.terminfo
    restic
    tmux
    exa
    bash-completion
    whois

    fd
    ripgrep

    rclone
    wireguard-tools

    usbutils
    pciutils
    git
  ];

  environment.variables.EDITOR = "vim";

  users.users.kloenk.shell = lib.mkOverride 75 pkgs.zsh;

  programs.zsh.enable = true;
  programs.mtr.enable = true;

  #users.users.root.shell = pkgs.fish;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBps9Mp/xZax8/y9fW1Gt73SkskcBux1jDAB8rv0EYUt cardno:000612029874"
  ];

  systemd.tmpfiles.rules = [
    "Q /persist 755 root - - -"
    "Q /persist/data 755 root - - -"

    "Q /persist/data/acme 750 nginx - - -"
    #"L /var/lib/acme - acme - - /persist/data/acme"
    #"L+ /etc/shadow - - - - /persist/data/shadow"
  ];
  services.resolved.dnssec = "false";
}
