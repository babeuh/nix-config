{ pkgs, lib, config, ... }:
let
  colors = config.colors;
in
{
  # TODO: move to user-specific config
  # need to login and 'export-tls-cert' to ~/.config/protonmail/bridge-v3 in cli mode
  services.protonmail-bridge = {
    enable = true;
    email = "me@rlglr.fr";
  };
  accounts.email = {
    # Global Settings
    maildirBasePath = "Mail";
    
    # Accounts
    accounts = {
      main = {
        primary = true;
        realName = "Raphael Le Goaller";
        address = "me@rlglr.fr";
        userName = "me@rlglr.fr";
        aliases = [
          "babeuh@rlglr.fr"
        ];

        passwordCommand = "${pkgs.libsecret}/bin/secret-tool lookup email me@rlglr.fr";
        imap = {
          host = "127.0.0.1";
          port = 1143;
          tls = {
            useStartTls = true;
            certificatesFile = "${config.xdg.configHome}/protonmail/bridge-v3/cert.pem";
          };
        };#
        smtp = {
          host = "127.0.0.1";
          port = 1025;
          tls = {
            useStartTls = true;
            certificatesFile = "${config.xdg.configHome}/protonmail/bridge-v3/cert.pem";
          };
        };

        mbsync = {
          enable = true;

          create = "both";
          expunge = "both";
          remove = "both";

          groups = {
            protonmail = {
              channels = {
                inbox = {
                  patterns = [
                    "INBOX"
                  ];
                };
                sent = {
                  farPattern = "Sent";
                  nearPattern = "Sent";
                };
                trash = {
                  farPattern = "Trash";
                  nearPattern = "Trash";
                };
              };
            };
          };
        };

        neomutt = {
          enable = true;
          extraMailboxes = [
            "Sent"
            "Trash"
          ];
          extraConfig = ''
            # SMTP
            set ssl_starttls = yes
            # IMAP
            set folder = imap://${config.accounts.email.accounts.main.imap.host}:${toString config.accounts.email.accounts.main.imap.port}/
            set imap_user = "${config.accounts.email.accounts.main.userName}"
            set imap_pass = "`${toString config.accounts.email.accounts.main.passwordCommand}`"
            unset imap_passive
            set imap_keepalive = 300
            # Config
            set send_charset = "utf-8"
            set assumed_charset = "iso-8859-1"
            set mail_check = 60
            set edit_headers = yes
            set sidebar_visible
            set sidebar_format = "%B%<F? [%F]>%* %<N?%N/>%S"
            set sidebar_short_path
            set mail_check_stats
            set color_directcolor
          '';
        };
      };
    };
  };

  programs.neomutt = {
    enable = true;
    vimKeys = true;
    editor = "nvim +':set textwidth=65' +':set colorcolumn=+0'";
    extraConfig = ''
      color normal        #${colors.foreground}        #${colors.background}        
      color error         #${colors.red}        #${colors.background}        
      color tilde         #${colors.background-alt}        #${colors.background}        
      color message       #${colors.cyan}        #${colors.background}        
      color markers       #${colors.red}        #${colors.background}        
      color attachment    #${colors.background-least}        #${colors.background}        
      color search        #${colors.purple}        #${colors.background}        
      color status        #${colors.yellow}        #${colors.background}        
      color indicator     #${colors.background-selection}        #${colors.yellow-bright}        
      color tree          #${colors.yellow-bright}        #${colors.background}        

      # basic monocolor screen
      mono  bold          bold
      mono  underline     underline
      mono  indicator     reverse
      mono  error         bold
    '';
  };

  programs.mbsync.enable = true;
  services.mbsync = {
    enable = true;
    frequency = "*:0/1";
  };
}
