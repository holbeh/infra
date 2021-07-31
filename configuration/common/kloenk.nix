{ lib, pkgs, config, ... }:

{
  nix.registry.kloenk = {
    from.type = "indirect";
    from.id = "kloenk";
    #to.url = "git+https://git.kloenk.dev/kloenk/nix";
    to.type = "git";
    to.url = "https://git.kloenk.dev/kloenk/nix";
    exact = false;
  };

  users.users.kloenk = {
    isNormalUser = true;
    uid = lib.mkDefault 1000;
    #initialPassword = lib.mkDefault "foobar";
    extraGroups = [ "wheel" "bluetooth" "libvirtd" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBps9Mp/xZax8/y9fW1Gt73SkskcBux1jDAB8rv0EYUt cardno:000611120054"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAEDZjcKdYViw9cPrLNkO37+1NgUj8Ul1PTlbXMMwlMR kloenk@kloenkX"
    ];
    packages = with pkgs; [
      wget
      tmux
      nload
      htop
      ripgrep
      exa
      bat
      progress
      pv
      file
      #elinks
      bc
      #zstd
      unzip
      jq
      neofetch
      onefetch
      sl
      tcpdump
      binutils
      nixfmt
      perl
    ];
  };

  programs.gnupg.agent = {
    enable = lib.mkDefault true;
    enableSSHSupport = true;
  };

  programs.ssh.knownHosts = {
    "kloenk.de" = {
      hostNames = [ "*.kloenk.de" ];
      certAuthority = true;
      publicKeyFile = toString ./server_ca.pub;
    };
    "kloenk.dev" = {
      hostNames = [ "*.kloenk.dev" ];
      certAuthority = true;
      publicKeyFile = toString ./server_ca.pub;
    };
  };
}
