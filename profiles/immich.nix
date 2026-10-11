{ config, ... }:

{
  services.immich = {
    enable = true;
    host = "127.0.0.1";
    port = 2283;
    mediaLocation = "/data/photos";
  };

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
