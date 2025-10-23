{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect
    
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "edge02-htz-hel-test";
  networking.domain = "";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOVWjF49VNIdYmmS/Ftnz2RtD+hiua4+LeSAJU2wqOE1'' ];
  system.stateVersion = "23.11";
}
