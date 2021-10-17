{ config, lib, ... }:

{

    # TODO: red5 ram erhöhen (bbb default setting)

    services.bigbluebutton.simple = {
        enable = true;
        domain = "bbb.kloenk.dev";
        ips = [ "195.39.221.27" "2001:678:bbc::27" ];
    };
    services.bigbluebutton.greenlight = {
        adminName = "Finn Behrens";
        adminEmail = "green+testing@kloenk.dev";
    };

    systemd.services.bbb-greenlight.environment.DB_HOST = lib.mkForce "/var/run/postgresql";
}