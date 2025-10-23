{
  description = "Sourcery's Machine Configuration!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    agenix.url = "github:ryantm/agenix";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
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
    disko,
    nixos-anywhere,
    ... }@inputs: {

      rpi3Image = nixos-raspberrypi.installerImages.rpi3;
      rpi4Image = nixos-raspberrypi.installerImages.rpi4;
      rpi5Image = nixos-raspberrypi.installerImages.rpi5;
      
      nixosConfigurations = {
        edge02-htz-hel-test = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            agenix.nixosModules.default
          ];
        };
      };
  };
}
