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
        secretEnv = config.petabyte.secrets."greenlight".path;
    };

    systemd.services.bbb-greenlight.environment.DB_HOST = lib.mkForce "/var/run/postgresql";

    petabyte.secrets."greenlight".owner = "greenlight";
    users.users.greenlight.extraGroups = [ "keys" ];

    users.users.bbb-akka-apps.group = "bbb-akka-apps";
    users.groups.bbb-akka-apps = {};

    users.users.bbb-akka-fsesl.group = "bbb-akka-fsesl";
    users.groups.bbb-akka-fsesl = {};

    users.users.bbb-etherpad-lite.group = "bbb-etherpad-lite";
    users.groups.bbb-etherpad-lite = {};

    users.users.bbb-html5.group = "bbb-html5";
    users.groups.bbb-html5 = {};

    users.users.bbb-soffice.group = "bbb-soffice";
    users.groups.bbb-soffice = {};

    users.users.bbb-webrtc-sfu.group = "bbb-webrtc-sfu";
    users.groups.bbb-webrtc-sfu = {};

    users.users.freeswitch.group = "freeswitch";
    users.groups.freeswitch = {};

    users.users.greenlight.group = "greenlight";
    users.groups.greenlight = {};

    users.users.kurento.group = "kurento";
    users.groups.kurento = {};

    users.users.turnserver.group = "turnserver";
    users.groups.turnserver = {};
}
