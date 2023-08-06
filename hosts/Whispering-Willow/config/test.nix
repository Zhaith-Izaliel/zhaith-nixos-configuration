{ ... }:

{
  services.inadyn = {
    enable = true;
    settings = ''
      period          = 300
      verify-address  = true

      provider default@dyndns.org {
        ssl         = true
        username    = ethereal-edelweiss.cloud-zhaith
        password    = "@password_placeholder@"
        hostname    = example.dyndns.org
      }
    '';
    passwordFile = "/var/run/inadyn-password";
    passwordPlaceholder = "@password_placeholder@";
  };
}

