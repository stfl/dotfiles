{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  imports = [
    ../../modules/home/desktop.nix
    ../../modules/home/emacs.nix
    ../../modules/home/pass.nix
    ../../modules/home/email.nix
  ];

  targets.genericLinux.enable = true;

  nixGLPrefix = getExe pkgs.nixgl.nixGLIntel;

  home.packages = with pkgs; [
    nixgl.nixGLIntel
    nvtopPackages.intel

    # -- rust
    rust-analyzer
    # rustfmt    # deb: install rustfmt
    # clippy     # deb: install rust-clippy

    dart-sass
    trunk
    cargo-binstall
  ];

  programs.git = {
    # userEmail = "s.lendl@proxmox.com";
    includes = [
      {
        # apply updated git configuration for every repo inside ~/work/proxmox/<repo>
        condition = "gitdir:${config.home.homeDirectory}/work/proxmox/";
        contents = {
          user = {
            email = "s.lendl@proxmox.com";
            name = "Stefan Lendl";
          };
          # commit.signOff = true;
          format = {
            # subjectPrefix = "PATCH {<<current-dir>>}";  # TODO this should be f.e. PATCH pve-common
            outputDirectory = "my-patches";
            # coverLetter = true;
            # to = "pve-devel@lists.proxmox.com";
          };
          sendEmail = {
            smtpencryption = "tls";
            smtpServer = "webmail.proxmox.com";
            smtpServerPort = 587;
            smtpUser = "s.lendl@proxmox.com";
            # smtpsslcertpath=;
            # to = "pve-devel@lists.proxmox.com";
            # smtpPass = "`${config.programs.rbw.package}/bin/rbw get webmail.proxmox.com`";
          };
        };
      }
      # {
      #   condition = "gitdir:${config.home.homeDirectory}/work/proxmox/proxmox-backup*/";
      #   contents = {
      #     format.to = "pbs-devel@lists.proxmox.com";
      #     sendEmail.to = "pbs-devel@lists.proxmox.com";
      #   };
      # }
      # {
      #   # condition = "gitdir:${config.home.homeDirectory}/work/proxmox/{pve-docs,pve-manager,pve-network,pve-commpon}/";
      #   condition = "gitdir:${config.home.homeDirectory}/work/proxmox/pve-manager/";
      #   contents = {
      #     format.to = "pve-devel@lists.proxmox.com";
      #     sendEmail.to = "pve-devel@lists.proxmox.com";
      #   };
      # }
    ];
  };

  accounts.email = {
    maildirBasePath = "Mail";
    accounts = {
      "proxmox" = {
        address = "s.lendl@proxmox.com";
        primary = true;
        realName = "Stefan Lendl";
        userName = "s.lendl";
        passwordCommand = "${config.programs.rbw.package}/bin/rbw get webmail.proxmox.com";
        # signature = {TODO};
        folders = {
          drafts = "Entw&APw-rfe";
          inbox = "Inbox";
          sent = "Gesendete Objekte";
        };
        imap = {
          host = "webmail.proxmox.com";
          # port = 993;
          tls.enable = true;
          # imapnotify = {
          #   enable = true;
          #   boxes = [
          #     "Inbox";
          #   ];
          # };
        };
        smtp = {
          host = "mail.proxmox.com";
          port = 25;
          tls.enable = false;
          # port =
        };
        msmtp = {
          enable = true;
          extraConfig = {
            auth = "off";
          };
        };
        mbsync = {
          enable = true;
          create = "both"; # TODO "maildir" // imap" // "both" ??
          # remove = "both";
        };
        # mu.enable = true;
        notmuch.enable = true;
        # thunderbird.enable = true;
      };
    };
  };
}
