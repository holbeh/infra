{
  description = "Infrastructure";

  inputs.nixpkgs = {
    type = "github";
    owner = "nixos";
    repo = "nixpkgs";
  };

  inputs.nix = {
    type = "github";
    owner = "nixos";
    repo = "nix";
    inputs.nixpkgs.follows = "/nixpkgs";
  };

  inputs.bbb = {
    type = "github";
    owner = "helsinki-systems";
    repo = "bbb4nix";
    flake = false;
  };

  inputs.kloenk.url = "git+https://git.kloenk.dev/kloenk/nix";
  inputs.kloenk.inputs.nixpkgs.follows = "/nixpkgs";
  inputs.kloenk.inputs.hydra.follows = "/nixpkgs";

  outputs = inputs@{ self, nixpkgs, nix, bbb, kloenk, ... }:
    let
      overlayCombined = system: [
        nix.overlay
        #home-manager.overlay
        self.overlay
        (overlays system)
      ];

      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      # Memoize nixpkgs for different platforms for efficiency.
      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
          overlays = (overlayCombined system);
        });

      # patche modules
      patchModule = system: {
        /* disabledModules =
             [
               "services/games/minecraft-server.nix"
               "tasks/auto-upgrade.nix"
               "services/networking/pleroma.nix"
               "services/web-apps/wordpress.nix"
             ];
           imports = [
             self.nixosModules.autoUpgrade
           ];
        */
        nixpkgs.overlays = [ (overlays system) nix.overlay self.overlay ];
      };

      overlays = system: final: prev: {
        utillinuxMinimal = final.util-linuxMinimal;
        #hydra = builtins.trace "eval hydra" hydra.packages.${system}.hydra;
      };

      hosts = import ./configuration/hosts;
      nixosHosts = nixpkgs.lib.filterAttrs
        (name: host: if host ? nixos then host.nixos else false) hosts;
      sourcesModule = {
        _file = ./flake.nix;
        _module.args.inputs = inputs;
      };
    in {
      overlay = final: prev:
        ((import ./pkgs/overlay.nix inputs final prev) // {

        });
      legacyPackages = forAllSystems (system: nixpkgsFor.${system});

      nixosConfigurations = (nixpkgs.lib.mapAttrs (name: host:
        (nixpkgs.lib.nixosSystem rec {
          system = host.system;
          modules = [
            {
              nixpkgs.overlays = [
                #home-manager.overlay
                self.overlay
              ];
            }
            nixpkgs.nixosModules.notDetected
            #home-manager.nixosModules.home-manager
            (import (./configuration + "/hosts/${name}/configuration.nix"))
            #kloenk.nixosModules.secrets
            kloenk.nixosModules.nftables
            #kloenk.nixosModules.deluge2
            #kloenk.nixosModules.firefox
            #kloenk.nixosModules.pleroma
            #kloenk.nixosModules.wordpress
            sourcesModule
            /* {
                 # disable home-manager manpage (breaks hydra see https://github.com/rycee/home-manager/issues/1262)
                 home-manager.users.kloenk.manual.manpages.enable = false;
               }
            */
            (patchModule host.system)
          ] ++ (if (if (host ? vm) then host.vm else false) then
            (nixpkgs.lib.singleton
              (import (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")))
          else
            [ ]);
        })) nixosHosts);

      nixosModules = { };
    };
}
