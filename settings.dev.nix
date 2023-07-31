{ pkgs, domain, ... }:
{
  _module.args.domain = "vps-dev.cerberus-systems.de";

  sops = {
    defaultSopsFile = ./secrets/vpsDev.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  sops.secrets = {
    serveo_id_rsa = {};
    serveo_known_hosts = {};
  };

  systemd.services.serveo = {
    description = "Serveo SSH tunnel";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.openssh}/bin/ssh -i %d/id_rsa \
          -o ServerAliveInterval=60 \
          -o UserKnownHostsFile=%d/known_hosts \
          -R ${domain}:80:localhost:8404 serveo.net
      '';
      Restart = "always";
      LoadCredential = [
        "id_rsa:/run/secrets/serveo_id_rsa"
        "known_hosts:/run/secrets/serveo_known_hosts"
      ];
      DynamicUser = true;
      ProtectSystem = "strict";
    };
  };
}