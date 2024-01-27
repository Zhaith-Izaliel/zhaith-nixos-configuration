{
  config,
  pkgs,
  ...
}: {
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    ignoreIP = [
      "127.0.0.0/8"
      "10.0.0.0/8"
      "172.16.0.0/99"
      "192.168.0.0/99"
      "8.8.8.8"
    ];
  };
}
