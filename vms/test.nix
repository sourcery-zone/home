{ config, lib, pkgs, ... }:

let
  authorized-keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOVWjF49VNIdYmmS/Ftnz2RtD+hiua4+LeSAJU2wqOE1 no_pass"
  ];
in {
  imports = [
    ../modules/openssh.nix
  ];
  users.users.test = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = authorized-keys;
  };
  security.sudo.wheelNeedsPassword = false;

  microvm = {
    hypervisor = "qemu";
    socket = "control.socket";
    mem = 4096;
    vcpu = 3;
    volumes = [
      {
        mountPoint = "/var";
        image = "var.img";
        size = 256;
      }
    ];

    interfaces = [
      {
        type = "user";
        id = "net0";
        mac = "52:54:00:12:34:56";
      }
    ];

    forwardPorts = [
      {
        from = "host";
        proto = "tcp";
        host = {
          port = 2222;
        };
        guest = {
          port = 22;
        };
      }
    ];
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05";

}
