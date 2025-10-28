{ config, lib, pkgs, ... }:

let
  hostname = "test-vm";
  pihole-domain = "localhost";
in {
  imports = [
    ../modules/openssh.nix
    ../modules/openssh.nix
    ../modules/podman.nix
    ../modules/caddy.nix
    ../modules/pihole.nix
    ../modules/postgresql.nix
  ];

  module.pihole.domain = pihole-domain;
  networking.hostName = hostname;
  services.postgresql.ensureDatabases = [ "gitea" "nextcloud" ];
}
