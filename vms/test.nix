{ config, lib, pkgs, ... }:

let
  authorized-keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOVWjF49VNIdYmmS/Ftnz2RtD+hiua4+LeSAJU2wqOE1 no_pass"
  ];
in {
  imports = [
    ../modules/openssh.nix
  ];
  virtualisation = {
    vmVariant = {
      virtualisation = {
        qemu.options = [ "-device virtio-vga -audio model=hda,driver=pipewire" ];
        memorySize = 6000;
        cores = 6;
        diskSize = 20000;
      };

      virtualisation.forwardPorts = [
        { from = "host"; host.port = 2222; guest.port = 22; }
      ]
      ;
    };
  };

  # never try to install a bootloader in the QEMU build-vm
  boot.loader.grub.enable = lib.mkForce false;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.generic-extlinux-compatible.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  # TODO check if you want to keep this
  boot.kernelPackages = pkgs.linuxPackages_6_12;

  networking.hostName = "home-test";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";
  environment.systemPackages = with pkgs; [
    fastfetch
  ];
  
  services.displayManager.autoLogin.user = "test"; #auto login the user
  
  users.users.test = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = authorized-keys;
  };
  users.users.root.openssh.authorizedKeys.keys = authorized-keys;
  security.sudo.wheelNeedsPassword = false;
  security.pam.enableSSHAgentAuth = true;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05";

}
