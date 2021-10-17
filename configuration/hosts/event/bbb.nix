{ config, lib, ... }:

{

    # TODO: red5 ram erhöhen (bbb default setting)

    services.bigbluebutton.simple = {
        enable = true;
        domain = "event.unterbachersee.de";
        ips = [ "46.4.108.116" "2001:678:bbc::27" ];
    };
    services.bigbluebutton.greenlight = {
        adminName = "Finn Behrens";
        adminEmail = "greenlight@kloenk.dev";
    };

    systemd.services.bbb-greenlight.environment.DB_HOST = lib.mkForce "/var/run/postgresql";
}