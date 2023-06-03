{ config, ... }:

{
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh ={
    enable = true;
    ports = [ 4242 ];
    openFirewall = true;
    settings.passwordAuthentication = false;
    allowSFTP = true;
    sftpServerExecutable = "internal-sftp";
  };


  users.extraUsers.lilith.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE72R8aIght+Ci0DjXvXJ4l1UZ2f7/phFHc5gfqJ16E4 virgil.ribeyre@protonmail.com"
  ];
}

