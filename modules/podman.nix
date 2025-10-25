{ config, pkgs, ... }: {
  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  networking.firewall = {
    trustedInterfaces = [ "podman0" "cni-podman0" ];
  };
}
