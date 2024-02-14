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

      provider default@ovh.com {
        ssl = true
        username = virgilribeyre.com-zhaith
        password = "@password_placeholder@"
        hostname = { www.virgilribeyre.com, virgilribeyre.com }
      }
    '';
    passwordFile = "/mnt/datas/inadyn/inadyn-password";
    passwordPlaceholder = "@password_placeholder@";
  };
}
