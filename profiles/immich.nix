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

  services.nginx.virtualHosts."photos.sslavos.com" = {
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

  services.cloudflared.tunnels."113fd93b-5514-4d9e-86d2-7eb0c6d7ea9e".ingress."photos.sslavos.com" = {
    service = "http://localhost:80";
  };
}
