{ config, lib, ... }:

{
  services.immich = {
    enable = true;
    host = "127.0.0.1";
    port = 2283;
    mediaLocation = "/mnt/pai/immich";
  };

  # /mnt/pai is exFAT: everything on it is owned by nextcloud:nextcloud (set by
  # the mount options), so immich gets access through the group, and the
  # module's own tmpfiles rule is dropped because it would try to chown.
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
    };
  };

  services.cloudflared.tunnels."113fd93b-5514-4d9e-86d2-7eb0c6d7ea9e".ingress."photos.sslavos.com" = {
    service = "http://localhost:80";
  };
}
