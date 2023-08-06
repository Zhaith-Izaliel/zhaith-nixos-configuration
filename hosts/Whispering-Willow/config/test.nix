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
        password    = ${builtins.readFile /var/run/inadyn-password}
        hostname    = example.dyndns.org
      }
    '';
  };
}

