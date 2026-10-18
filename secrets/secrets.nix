let
	rnl-simaolavos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA3jJ34aDHRG8KLbSU/4mhfUblVte4vjBPpcOocWKEkE root@RNL-SimaoLavos";
	zeno = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfXG5G95rmqd9G9sJCujtZTJehQqW8z83JzBcaKDPTc root@nixos";
	hosts = [ rnl-simaolavos zeno ];
in {
    "vault-tunnel.age".publicKeys = [ zeno rnl-simaolavos ];
    "vw-secrets.age".publicKeys = [ zeno rnl-simaolavos ];
    "nextcloud-secret.age".publicKeys = [ zeno rnl-simaolavos ];
    "grafana-secret-key.age".publicKeys = [ zeno rnl-simaolavos ];
    "grafana-secret.age".publicKeys = [ zeno rnl-simaolavos ];
    "searxng-secret.age".publicKeys = [ zeno rnl-simaolavos ];
    "slskd-secrets.age".publicKeys = [ zeno rnl-simaolavos ];
    "couchdb-secrets.age".publicKeys = [ zeno rnl-simaolavos ];
    "matrix-secrets.age".publicKeys = [ zeno rnl-simaolavos ];
    "kavita-token.age".publicKeys = [ zeno rnl-simaolavos ];
    "back2you-htpasswd.age".publicKeys = [ zeno rnl-simaolavos ];
    "cloudflare-ddns-token.age".publicKeys = [ zeno rnl-simaolavos ];
    "mail-password-hash.age".publicKeys = [ zeno rnl-simaolavos ];
    "mail-relay-sasl.age".publicKeys = [ zeno rnl-simaolavos ];
    "tutoring-app-env.age".publicKeys = [ zeno ];
  }
