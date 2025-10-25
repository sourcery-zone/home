{
  description = "Sourcery's Machine Configuration!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    agenix.url = "github:ryantm/agenix";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
    secrets.url = "git+ssh://sourcery.github.com/sourcery-zone/secrets";
  };

  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  outputs = {
    self,
    nixpkgs,
    agenix,
    nixos-raspberrypi,
    secrets,
    ... }@inputs: {

      rpi3Image = nixos-raspberrypi.installerImages.rpi3;
      rpi4Image = nixos-raspberrypi.installerImages.rpi4;
      rpi5Image = nixos-raspberrypi.installerImages.rpi5;
      
      nixosConfigurations = {
        test-vm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./systems/test.nix
            ./modules/openssh.nix
            ./modules/podman.nix
            ./modules/caddy.nix
            #./modules/pihole.nix TODO pass the argument
            agenix.nixosModules.default
            {
              age.secrets = secrets.age;
            }
          ];
        };
      };
  };
}
