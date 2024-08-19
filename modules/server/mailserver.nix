{
  config,
  lib,
  extra-types,
  options,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.hellebore.server.mail;
  domain = "${cfg.subdomain}.${config.networking.domain}";
in {
  options.hellebore.server.mail =
    {
      inherit
        (options.mailserver)
        domains
        loginAccounts
        rejectRecipients
        rejectSender
        certificateDomains
        fullTextSearch
        monitoring
        mailDirectory
        mailboxes
        ;
    }
    // extra-types.server-app {
      name = "Mail Server";
      group = "virtualMail";
      user = "virtualMail";
    };

  config = mkIf cfg.enable {
    mailserver = {
      inherit
        (cfg)
        domains
        loginAccounts
        rejectRecipients
        rejectSender
        certificateDomains
        fullTextSearch
        monitoring
        mailDirectory
        mailboxes
        ;

      enable = true;
      vmailUserName = cfg.user;
      vmailGroupName = cfg.user;
      fqdn = domain;
      useFsLayout = true;
      certificateScheme = "acme-nginx";
      enableSubmission = true;
      enableSubmissionSsl = false;
      enableImap = true;
      enableImapSsl = false;
      openFirewall = true;

      hierarchySeparator = "/";
    };

    services.nginx.virtualHosts.${config.networking.domain} = {
      enableACME = true;
      forceSSL = true;
    };
  };
}
