{ config, pkgs, ... }:

# Tutoring app (github.com/JoaoCodificacoes/moms-scheduling-app).
# Runs the repo's docker-compose.prod.yml as one systemd unit: postgres,
# migrate, api and its own cloudflared (separate tunnel, ritanatario.com).
# Kept as Compose rather than oci-containers because the stack relies on
# healthcheck/completion ordering and a pinned cloudflared IP.
# docker-compose.prod.yml is copied into ${dir} by hand; the env file comes
# from agenix.
let
  dir = "/var/lib/tutoring-app";
  compose = "${pkgs.docker-compose}/bin/docker-compose -p tutoring-app --env-file ${dir}/.env.prod -f ${dir}/docker-compose.prod.yml";
in
{
  age.secrets.tutoring-app-env.file = ../secrets/tutoring-app-env.age;

  virtualisation.docker.enable = true;

  systemd.tmpfiles.rules = [
    "d ${dir} 0700 root root -"
    # The compose file reads .env.prod from its own folder
    "L+ ${dir}/.env.prod - - - - ${config.age.secrets.tutoring-app-env.path}"
  ];

  systemd.services.tutoring-app = {
    description = "Tutoring app (Compose stack)";
    requires = [ "docker.service" ];
    after = [ "docker.service" "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = dir;
      # "-": a failed pull (no internet at boot) doesn't stop the stack starting
      ExecStartPre = "-${compose} pull";
      ExecStart = "${compose} up -d --remove-orphans";
      # No -v: the postgres volume is kept
      ExecStop = "${compose} down";
    };
  };

  # Picks up new GHCR images. Not Watchtower: it recreates containers one at
  # a time and ignores depends_on, so a new api would start before migrate.
  # Not a restart of tutoring-app either: its ExecStop takes the stack down.
  # up -d only recreates containers whose image changed.
  systemd.services.tutoring-app-update = {
    description = "Pull and redeploy tutoring app images";
    # requisite: skip (don't start the stack) if it was stopped on purpose
    requisite = [ "tutoring-app.service" ];
    after = [ "tutoring-app.service" ];
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = dir;
    };
    # --profile ops also refreshes the backup image used by `run --rm backup`
    script = ''
      ${compose} --profile ops pull
      ${compose} up -d --remove-orphans
    '';
  };

  systemd.timers.tutoring-app-update = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:0/15";
      RandomizedDelaySec = "60";
    };
  };
}
