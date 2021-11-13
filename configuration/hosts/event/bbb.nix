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
        bbbEndpoint = lib.mkForce "https://event.unterbachersee.de/bigbluebutton/";
        environment = {
          SMTP_SERVER = "smtp.ionos.de";
          SMPT_PORT = "587";
          SMTP_DOMAIN = "smtp.ionos.de";
          SMTP_USERNAME = "event@wass-er.com";
          SMTP_AUTH = "plain";
          SMTP_STARTTLS_AUTO = "true";
          SMTP_SENDER = "event@wass-er.com";
        };
        secretEnv = config.petabyte.secrets."greenlight".path;
    };

    services.bigbluebutton.akka-apps.secretsFile = config.petabyte.secrets."bbb-akka-apps".path;
    services.bigbluebutton.coturn.secretsFile = config.petabyte.secrets."bbb-web-turn".path;
    services.bigbluebutton.web.secretsFile = config.petabyte.secrets."bbb-web.properties".path;

    systemd.services.bbb-greenlight.environment.DB_HOST = lib.mkForce "/var/run/postgresql";

    users.users.greenlight.extraGroups = [ "keys" ];
    users.users.bbb-web.extraGroups = [ "keys" ];
    petabyte.secrets."greenlight".owner = "greenlight";
    petabyte.secrets."bbb-akka-apps".owner = "root";
    petabyte.secrets."bbb-web-turn".owner = "bbb-web";
    petabyte.secrets."bbb-web.properties".owner = "bbb-web";

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
