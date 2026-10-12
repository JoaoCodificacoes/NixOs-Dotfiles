{ config, ... }:
{
  # Just the token, with Zone:DNS:Edit on sslavos.com.
  age.secrets.cloudflare-ddns-token.file = ../secrets/cloudflare-ddns-token.age;

  # Keeps the DNS-only A records pointing at the home IP.
  services.cloudflare-dyndns = {
    enable = true;
    apiTokenFile = config.age.secrets.cloudflare-ddns-token.path;
    domains = [ "photos.sslavos.com" ];
  };
}
