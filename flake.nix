{
  description = "Sourcery's Machine Configuration!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    agenix.url = "github:ryantm/agenix";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
    secrets.url = "git+ssh://sourcery.github.com/sourcery-zone/secrets";
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
      "https://microvm.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
      "microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys="
    ];
  };

  outputs = {
    self,
    nixpkgs,
    agenix,
    nixos-raspberrypi,
    secrets,
    microvm,
    ... }@inputs: let
      system = "x86_64-linux";
    in {

      rpi3Image = nixos-raspberrypi.installerImages.rpi3;
      rpi4Image = nixos-raspberrypi.installerImages.rpi4;
      rpi5Image = nixos-raspberrypi.installerImages.rpi5;
      
      nixosConfigurations = {
        test-vm = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            microvm.nixosModules.microvm
            ./vms/test.nix
          ];
        };
        test-config = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./systems/test.nix
            agenix.nixosModules.default
            {
              age.secrets = secrets.age;
            }
          ];
        };
      };
  };
}
