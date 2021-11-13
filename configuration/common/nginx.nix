{ lib, pkgs, config, ... }:

{
  security.acme.email = lib.mkDefault "ca+infra@kloenk.dev";
  security.acme.acceptTerms = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.nginx = {
    enable = true;
    package = pkgs.nginxMainline.override {
      modules = with pkgs.nginxModules; [ moreheaders ];
    };

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    sslCiphers = "EECDH+AESGCM:EECDH+AES256";
    sslProtocols = "TLSv1.3 TLSv1.2";

    commonHttpConfig = ''
      map $scheme $hsts_header {
        https "max-age=31536000; includeSubdomains; preload";
      }

      map $sent_http_content_type $cacheable_types {
        "text/html"               "public; max-age=3600; must-revalidate";
        "text/plain"              "public; max-age=3600; must-revalidate";
        "text/css"                "public; max-age=15778800; immutable";
        "application/javascript"  "public; max-age=15778800; immutable";
        "font/woff2"              "public; max-age=15778800; immutable";
        "application/xml"         "public; max-age=3600; must-revalidate";
        "image/jpeg"              "public; max-age=15778800; immutable";
        "image/png"               "public; max-age=15778800; immutable";
        "image/webp"              "public; max-age=15778800; immutable";
        default                   "public; max-age=1209600";
      }

      charset utf-8;
      map $scheme $hsts_header {
        https "max-age=31536000; includeSubdomains; preload";
      }

      add_header Referrer-Policy "no-referrer-when-downgrade" always;
      add_header Strict-Transport-Security $hsts_header always;
      add_header X-Content-Type-Options "nosniff";
      add_header X-Frame-Options "SAMEORIGIN";
      add_header X-Xss-Protection "1; mode=block";

      # This might create errors
      proxy_cookie_path / "/; secure; HttpOnly; SameSite=strict";
    '';
  };
}
