let
  makeHost = { host, port ? 62954, user ? "kloenk", prometheusExporters ? [
    "node-exporter"
    "nginx-exporter"
    #"nixos-exporter"
  ], hostname ? "${user}@${host}:${toString port}", server ? false, ...
    }@extraArgs:
    ({
      nixos = true;
      system = "x86_64-linux";
    } // extraArgs // {
      host.ip = host;
      host.port = port;
      host.user = user;
      inherit hostname prometheusExporters server;
    });

in {
  bbb-testing = makeHost {
    host = "192.168.178.239";
    vm = true;
  };
}
