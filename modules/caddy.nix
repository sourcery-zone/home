{ config, pkgs, ... }:

let
  caddy-with-plugins = pkgs.caddy.withPlugins {
    plugins = [
      "github.com/caddy-dns/cloudflare@v0.2.1"
      "github.com/caddy-dns/acmedns@v0.4.1"
    ];
    hash = "sha256-bYA8/iNw7lvUNLtTBSJdPB/W+sNs4l6VtNS6WBF97qw=";
  };
in {
  age.secrets.cloudflare = {
    mode = "0400";
    owner = "caddy";
    group = "caddy";
  };
  
  services.caddy = {
    package = caddy-with-plugins;
    enable = true;
    environmentFile = config.age.secrets.cloudflare.path;
    globalConfig =
      ''
        admin 0.0.0.0:2019
        metrics {
          per_host
        }
      '';
    extraConfig =
      ''
        (cloudflare) {
          tls {
            dns cloudflare {env.CLOUDFLARE_API_KEY}
            resolvers 1.1.1.1 1.0.0.1
          }
        }
      '';
  };
}
