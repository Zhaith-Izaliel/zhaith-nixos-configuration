{...}: {
  services.inadyn = {
    enable = true;
    settings = ''
      period          = 300
      verify-address  = true

      provider default@ovh.com {
        ssl         = true
        username    = ethereal-edelweiss.cloud-zhaith
        password    = "@password_placeholder@"
        hostname    = { nextcloud.ethereal-edelweiss.cloud, jellyfin.ethereal-edelweiss.cloud, books.ethereal-edelweiss.cloud, ethereal-edelweiss.cloud }
      }
    '';
    passwordFile = "/var/run/inadyn-password";
    passwordPlaceholder = "@password_placeholder@";
  };
}
