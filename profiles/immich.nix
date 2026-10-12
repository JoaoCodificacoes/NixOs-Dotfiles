{ config, lib, ... }:

{
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    port = 2283;
    mediaLocation = "/mnt/pai/immich";
  };

  users.users.immich.extraGroups = [ "nextcloud" ];
  systemd.tmpfiles.settings.immich = lib.mkForce { };
  systemd.tmpfiles.rules = [
    "d /mnt/pai/immich 0770 nextcloud nextcloud - -"
  ];
  systemd.services.immich-server.unitConfig.RequiresMountsFor = "/mnt/pai";

  # Served directly from the home IP (DNS-only A record), not through the
  # Cloudflare tunnel, so uploads are not capped at 100 MB.
  services.nginx.virtualHosts."photos.sslavos.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:2283/";
      proxyWebsockets = true;
      extraConfig = ''
        client_max_body_size 0;
        proxy_request_buffering off;
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
        send_timeout 600s;
      '';
    };
  };

  security.acme.acceptTerms = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
