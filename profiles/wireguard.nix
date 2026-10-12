{ config, pkgs, ... }:
{
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];
    listenPort = 51820;

    # Created on first start; read the public half with
    # `sudo wg show wg0 public-key`.
    privateKeyFile = "/var/lib/wireguard/private";
    generatePrivateKeyFile = true;

    peers = [
      {
        name = "wlden";
        publicKey = "hwAkhYJUSWO919jkZq52UC5MX3ktqhTl+E326crTtAc=";
        allowedIPs = [ "10.100.0.2/32" ];
      }
    ];
  };

  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
    trustedInterfaces = [ "wg0" ];
  };

  # Lets peers reach the LAN and the internet through zeno.
  networking.nat = {
    enable = true;
    externalInterface = "enp0s25";
    internalInterfaces = [ "wg0" ];
  };

  environment.systemPackages = [ pkgs.wireguard-tools ];
}
