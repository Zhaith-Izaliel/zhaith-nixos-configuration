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
        extraVirtualAliases
        ;
    }
    // extra-types.server-app {
      inherit domain;
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
        extraVirtualAliases
        ;

      enable = true;
      vmailUserName = cfg.user;
      vmailGroupName = cfg.user;
      fqdn = cfg.domain;
      useFsLayout = true;
      certificateScheme = "acme-nginx";
      enableSubmission = true;
      enableSubmissionSsl = true;
      enableImap = true;
      enableImapSsl = true;
      openFirewall = true;

      hierarchySeparator = "/";
    };

    services.nginx.virtualHosts.${config.networking.domain} = {
      enableACME = true;
      forceSSL = true;
    };

    services.fail2ban.jails = {
      postfix = {
        settings = {
          port = "smtp,submission,submissions";
          banaction = "%(banaction_allports)s";
          filter = ''postfix[mode=aggressive]'';
          maxretry = 3;
          bantime = 14400;
          findtime = 14400;
        };
      };

      dovecot = {
        settings = {
          port = "pop3,pop3s,imap,imaps";
          banaction = "%(banaction_allports)s";
          filter = ''dovecot[mode=aggressive]'';
          maxretry = 3;
          bantime = 14400;
          findtime = 14400;
        };
      };
    };
  };
}
