{ lib, pkgs, config, ... }:

{
  /* systemd.network.netdevs."30-y0sh0" = {
       netdevConfig = {
         Kind = "wireguard";
         Name = "y0sh0";
       };
       wireguardConfig = {
         PrivateKeyFile = config.petabyte.secrets."y0sh0.key".path;
       };
       wireguardPeers = [{ # y0sh
         wireguardPeerConfig = {
           AllowedIPs = [ "0.0.0.0/0" "::/0" ];
           PublicKey = "hsz2Ztrzos4zMM5bQumiD08jsyc4EhHA/PaqTDsfqh0=";
           Endpoint = "helium.00y.de:27671";
           PersistentKeepalive = 21;
         };
       }];
     };

     systemd.network.networks."30-y0sh0" = {
       name = "y0sh0";
       linkConfig = { RequiredForOnline = "no"; };
       addresses = [
         { addressConfig.Address = "195.39.221.27/32"; }
         { addressConfig.Address = "2001:678:bbc::27/128"; }
       ];
       routes = [{ routeConfig.Destination = "195.39.221.0/24"; }];
     };
  */

  networking.wg-quick.interfaces.y0sh0 = {
    address = [ "195.39.221.27/32" "2001:678:bbc::27/128" ];
    privateKeyFile = config.petabyte.secrets."y0sh0.key".path;
    peers = [{
      allowedIPs = [ "0.0.0.0/0" "::/0" ];
      endpoint = "helium.00y.de:27671";
      publicKey = "hsz2Ztrzos4zMM5bQumiD08jsyc4EhHA/PaqTDsfqh0=";
      persistentKeepalive = 21;
    }];
  };

  users.users.systemd-network.extraGroups = [ "keys" ];
  petabyte.secrets."y0sh0.key".owner = "systemd-network";
}
