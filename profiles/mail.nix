{ config, inputs, lib, ... }:
let
  fqdn = "mail.sslavos.com";
  webmail = "webmail.sslavos.com";
  relay = "[smtp-relay.brevo.com]:587";
in
{
  imports = [ inputs.simple-nixos-mailserver.nixosModules.default ];

  # Output of `nix-shell -p mkpasswd --run 'mkpasswd -s'`.
  age.secrets.mail-password-hash.file = ../secrets/mail-password-hash.age;

  # One line: [smtp-relay.brevo.com]:587 <smtp user>:<smtp password>
  age.secrets.mail-relay-sasl = {
    file = ../secrets/mail-relay-sasl.age;
    owner = config.services.postfix.user;
  };

  mailserver = {
    enable = true;
    stateVersion = 5;
    inherit fqdn;
    domains = [ "sslavos.com" ];

    # Certificate issued through the nginx vhost below.
    x509.useACMEHost = fqdn;

    # AdGuard already owns port 53.
    localDnsResolver = false;

    accounts."me@sslavos.com" = {
      hashedPasswordFile = config.age.secrets.mail-password-hash.path;
      aliases = [ "postmaster@sslavos.com" ];
    };
  };

  # The home IP is residential, so outgoing mail goes through Brevo.
  services.postfix.settings.main = {
    relayhost = [ relay ];
    smtp_sasl_auth_enable = true;
    smtp_sasl_password_maps = "texthash:${config.age.secrets.mail-relay-sasl.path}";
    smtp_sasl_security_options = "noanonymous";
    smtp_tls_security_level = lib.mkForce "encrypt";
  };

  # Served directly from the home IP (DNS-only A record), like photos.
  services.roundcube = {
    enable = true;
    hostName = webmail;
    extraConfig = ''
      $config['imap_host'] = "ssl://${fqdn}";
      $config['smtp_host'] = "ssl://${fqdn}";
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
      $config['username_domain'] = "sslavos.com";
    '';
  };

  # Roundcube reaches the mail server locally instead of via the router.
  networking.hosts."127.0.0.1" = [ fqdn ];

  # Only here to issue the mail server certificate.
  services.nginx.virtualHosts.${fqdn} = {
    enableACME = true;
    forceSSL = true;
    locations."/".return = "301 https://${webmail}$request_uri";
  };

  services.cloudflare-dyndns.domains = [ fqdn webmail ];

  security.acme.acceptTerms = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
