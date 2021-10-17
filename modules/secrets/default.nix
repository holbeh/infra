{ config, lib, pkgs, ... }:

with lib;

let
  secret-file = types.submodule ({ ... }@moduleAttrs: {
    options = {
      name = mkOption {
        type = types.str;
        default = moduleAttrs.config._module.args.name;
      };
      path = mkOption {
        type = types.str;
        readOnly = true;
        default = "/run/secrets/${removeSuffix ".gpg" (baseNameOf moduleAttrs.config.source-path)}";
      };
      mode = mkOption {
        type = types.str;
        default = "0400";
      };
      owner = mkOption {
        type = types.str;
        default = "root";
      };
      group-name = mkOption {
        type = types.str;
        default = "root";
      };
      source-path = mkOption {
        type = types.str;
        default = "${../../secrets + "/${config.networking.hostName}/${moduleAttrs.config.name}.gpg"}";
      };
      encrypted = mkOption {
        type = types.bool;
        default = true;
      };
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  });
  enabledFiles = filterAttrs (n: file: file.enable) config.petabyte.secrets;

  mkDeploySecret = file: pkgs.writeScript "deploy-secret-${removeSuffix ".gpg" (baseNameOf file.source-path)}.sh" ''
    #!${pkgs.runtimeShell}
    set -eu pipefail

    function fail() {
      rm /run/secrets/tmp/${file.name}
      echo "failed to decrypt ${file.path}" >&2
      exit 1
    }

    if [ ! -f "${file.path}" ]; then
      umask 0077
      echo "${file.source-path} -> ${file.path}"
      ${if file.encrypted then ''
        ${pkgs.gnupg}/bin/gpg --decrypt ${escapeShellArg file.source-path} > /run/secrets/tmp/${escapeShellArg (baseNameOf file.name)} && mv /run/secrets/tmp/${escapeShellArg (baseNameOf file.name)} ${file.path} || fail
      '' else ''
        cat ${escapeShellArg file.source-path} > ${file.path}
      ''}
    fi
    chown ${escapeShellArg file.owner}:${escapeShellArg file.group-name} ${escapeShellArg file.path}
    chmod ${escapeShellArg file.mode} ${escapeShellArg file.path}
  '';

in {
  options.petabyte.secrets = mkOption {
    type = with types; attrsOf secret-file;
    default = {};
  };
  config = mkIf (enabledFiles != {}) {
    system.activationScripts.setup-secrets = let
      files = unique (map (flip removeAttrs ["_module"]) (attrValues enabledFiles));
      script = ''
        echo setting up secrets...
        mkdir -p /run/secrets
        mkdir -p /run/secrets/tmp
        chown root:root /run/secrets
        chmod 0755 /run/secrets
        ${concatMapStringsSep "\n" (file: ''
          ${mkDeploySecret file} || echo "failed to deploy ${file.source-path} to ${file.path}"
        '') files}
      '';
    in stringAfter [ "users" "groups" ] "source ${pkgs.writeText "setup-secrets.sh" script}";
  };
}
