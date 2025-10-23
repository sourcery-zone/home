{ pkgs, config, lib, ... }:
let
  cfg = config.module.pihole;
in {
  options = {
    module.pihole.domain = lib.mkOption {
      type = lib.types.str;
      description = "Domain name to serve Pi-hole admin UI";
    };
  };

  config = {
    services.unbound = {
      enable = true;
      settings.server = {
        # listen everywhere, let access-control and firewall gate it
        interface = [ "0.0.0.0" "::0" ];
        access-control = [
          # localhost
          "127.0.0.0/8 allow"

          # Tailscale IPv4 CGNAT range
          "100.64.0.0/10 allow"

          # Podman default bridge on the same host
          "10.88.0.1/16 allow"

          # everything else deined
          "0.0.0.0/0 refuse"
        ];
        port = "5335";
      };
    };

    networking.firewall.interfaces."podman0".allowedUDPPorts = [ 5335 ];
    networking.firewall.interfaces."podman0".allowedTCPPorts = [ 5335 ];

    # Create the bind-mount dirs for Pi-hole
    systemd.tmpfiles.rules = [
      "d /var/lib/pihole 0755 root root -"
    ];

    virtualisation.oci-containers.containers = {
      pihole = {
        autoStart = true;
        image = "pihole/pihole:2025.08.0";
        volumes = [
          "/var/lib/pihole:/etc/pihole/"
        ];
        # publish DNS + UI
        ports = [
          "53:53/udp"
          "53:53/tcp"
          "8053:80/tcp"
        ];

        environment = {
          TZ = "Europe/Amsterdam";
          CUSTOM_CACHE_SIZE = "0";
          DNSSEC = "true";
          REV_SERVER = "true";
          VIRTUAL_HOST = cfg.domain;
          WEBTHEME = "default-darker";
          FTLCONF_webserver_api_password = "";
          FTLCONF_dns_upstreams = "host.containers.internal#5335";
        };
      };
    };

    services.caddy.virtualHosts = {
      "${cfg.domain}".extraConfig = ''
        reverse_proxy http://localhost:8053
      tls {
        import cloudflare
      }
      '';
    };

    # Ensure Pi-hole starts after Unbound and network
    systemd.services."podman-pihole".after = [
      "unbound.service"
      "network-online.target"
    ];
    systemd.services."podman-pihole".wants = [
      "unbound.service"
      "network-online.target"
    ];

    systemd.services.pihole-exporter = {
      description = "Pi-hole Prometheus exporter";
      wants = [ "network-online.target" ];
      after  = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.prometheus-pihole-exporter}/bin/pihole-exporter";
        Environment = [
          "PIHOLE_HOSTNAME=localhost"
          "PIHOLE_PORT=8053"
          "PORT=9617"
        ];
        Restart = "on-failure";

        DynamicUser = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectControlGroups = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        CapabilityBoundingSet = "";
        AmbientCapabilities = "";
        RestrictRealtime = true;
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
        SystemCallFilter = [ "@system-service" ];
      };
    };
  };
}
