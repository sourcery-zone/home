{ config, pkgs, ... }: {
  services.openssh = {
    enable = true;
    settings = {
      UseDns = false;
      GSSAPIAuthentication = false;  # avoid Kerberos/GSSAPI delays
      PrintMotd = false;             # skip motd scripts
      PrintLastLog = false;          # avoids slow lastlog host lookups
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };

    # TODO make it an option
    # openFirewall = false;

    allowSFTP = false;
    extraConfig = ''
      AllowTcpForwarding yes
      X11Forwarding no
      AllowAgentForwarding no
      AllowStreamLocalForwarding no
      AuthenticationMethods publickey
    '';
  };
}
