{ config, lib, pkgs, ... }:

let
  pihole-domain = "localhost";
in {
  imports = [
    ./test
    ../vms/test.nix
    ../modules/openssh.nix
    ../modules/podman.nix
    ../modules/caddy.nix
    ../modules/pihole.nix
    ../modules/postgresql.nix
  ];

  module.pihole.domain = pihole-domain;
  services.postgresql.ensureDatabases = [ "gitea" "nextcloud" ];
}
