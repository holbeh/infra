{ config, lib, ... }:

{

    # TODO: red5 ram erhöhen (bbb default setting)

    services.bigbluebutton.simple = {
        enable = true;
        domain = "event.unterbachersee.de";
        ips = [ "46.4.108.116" "2a01:4f8:141:4fc::2" ];
    };
    services.bigbluebutton.greenlight = {
        adminName = "Finn Behrens";
        adminEmail = "greenlight@kloenk.dev";
    };

    systemd.services.bbb-greenlight.environment.DB_HOST = lib.mkForce "/var/run/postgresql";
}
