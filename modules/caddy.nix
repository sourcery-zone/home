{ config, pkgs, ... }:

let
  caddy-with-plugins = pkgs.caddy.withPlugins {
    plugins = [
      "github.com/caddy-dns/cloudflare@v0.2.1"
      "github.com/caddy-dns/acmedns@v0.4.1"
    ];
    hash =
    if pkgs.stdenv.hostPlatform.isAarch64
    then "sha256-rf8ETPUwAiYASyGn/c8YKTh3OOlq1vfvELzM9I1tvr4="
    else "sha256-bYA8/iNw7lvUNLtTBSJdPB/W+sNs4l6VtNS6WBF97qw=";
  };
in {
  age.secrets = {
    cloudflare.file = ../secrets/cloudflare.age;
  };
  
  services.caddy = {
    package = caddy-with-plugins;
    enable = true;
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
            dns cloudflare $(cat ${config.age.secrets.cloudflare.path})
            resolvers 1.1.1.1 1.0.0.1
          }
        }
      '';
  };
}
