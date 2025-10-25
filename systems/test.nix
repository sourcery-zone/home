{ config, lib, pkgs, ... }:

{
  imports = [
    ../modules/openssh.nix
  ];

  services.openssh.openFirewall = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # TODO check if you want to keep this
  boot.kernelPackages = pkgs.linuxPackages_6_12;
  virtualisation.vmVariant = {
    virtualisation = {
      qemu.options = [
        "-device virtio-vga -audio model=hda,driver=pipewire"
      ];
      memorySize = 6000;
      cores = 6;
      diskSize = 20000;
      forwardPorts = [
        {
          from = "host";
          host.port = 2221;
          guest.port = 22;
        }
      ];
    };
  };

  networking.hostName = "home-test";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";
  environment.systemPackages = with pkgs; [
    fastfetch
  ];
  
  services.displayManager.autoLogin.user = "test"; #auto login the user
  
  users.users.test = {
    isNormalUser = true;
    password = "12345";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOVWjF49VNIdYmmS/Ftnz2RtD+hiua4+LeSAJU2wqOE1 no_pass"
    ];
  };
  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05";

}
