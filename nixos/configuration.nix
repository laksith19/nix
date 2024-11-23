{
  config,
  pkgs,
  pkgs-unstable,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "America/Los_Angeles";

  hardware = {
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;

    amdgpu.amdvlk.support32Bit.enable = true;
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Linux moment default LTS kernel breaks USB-C display and thunderbolt
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.luks.devices."luks-4dd038a9-c121-4b7b-b4fe-a0a65a6b81ea".device = "/dev/disk/by-uuid/4dd038a9-c121-4b7b-b4fe-a0a65a6b81ea";
  };

  # TODO: Move wireguard config here, rather than impure import in network manager
  networking = {
    hostName = "quirrel";
    networkmanager.enable = true;
    firewall.allowedUDPPorts = [
      51820 # Wireguard client
    ];
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  users = {
    users.laksith = {
      uid = 1000;
      isNormalUser = true;
      description = "laksith";
      extraGroups = ["networkmanager" "wheel" "video" "wireshark"];
      packages = with pkgs; [
        zoom-us
        pkgs-unstable.zed-editor
      ];
    };
  };

  environment = {
    systemPackages = with pkgs; [
      # Utils
      tmux
      wget
      fastfetch
      htop
      git
      wireshark-qt
      ripgrep
      fzf

      # CLI - EyeCandy
      lsd
      bat

      # GUI - sway
      waybar # alt. bar
      rofi-wayland # alt. dmenu launcher
      grim # Screenshot
      slurp # Screenshot
      wl-clipboard # Clipboard
      mako # Notifications
      xfce.thunar # File Manager

      # Wayland Firefox with screen-sharing support
      (wrapFirefox (firefox-unwrapped.override {pipewireSupport = true;}) {})
      pavucontrol # Audio control
      networkmanagerapplet # nm-applet
      pulseaudio # Get access to pactl for volumekeys
      wdisplays # Monitors config
      blueberry # for bluetooth config
      vlc # cause you need it you dummy
      abiword # word processor
      signal-desktop # well this u need i guess (should I just get discord as well...)
      remmina # VNC / SPICE client
    ];
    sessionVariables = {
      XDG_CURRENT_DESKTOP = "sway";
      XDG_SESSION_TYPE = "wayland";
    };
  };

  programs = {
    wireshark.enable = true;

    steam.enable = true;

    seahorse.enable = true;

    light.enable = true;

    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    zsh = {
      enable = true;
      promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      configure = {
        customRC = ''
          set nocompatible            " disable compatibility to old-time vi
          set showmatch               " show matching
          set ignorecase              " case insensitive
          set mouse=v                 " middle-click paste with
          set hlsearch                " highlight search
          set incsearch               " incremental search
          set tabstop=2               " number of columns occupied by a tab
          set softtabstop=2           " see multiple spaces as tabstops so <BS> does the right thing
          set expandtab               " converts tabs to white space
          set shiftwidth=2            " width for autoindents
          set autoindent              " indent a new line the same amount as the line just typed
          set number                  " add line numbers
          set wildmode=longest,list   " get bash-like tab completions
          set mouse=a                 " enable mouse click
          set clipboard=unnamedplus   " using system clipboard
          set cursorline              " highlight current cursorline
          set linebreak               " Insert EOL's breaking at
          set breakat=" "
          set breakindent             " break
          set ttyfast                 " Speed up scrolling in Vim

          filetype plugin on
          filetype plugin indent on   " allow auto-indenting depending on file type

          syntax on                   " syntax highlighting

        '';
      };
    };
  };

  # Nerd fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["JetBrainsMono" "Noto"];})
  ];

  security = {
    pam.services."laksith".enableGnomeKeyring = true; # Unlock on login
    rtkit.enable = true;
    polkit.enable = true;
  };

  services = {
    gnome.gnome-keyring.enable = true;

    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
          user = "greeter";
        };
      };
    };

    hardware.bolt.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  stylix = {
    enable = true;
    image = ./wallpaper.png;
    polarity = "dark";

    fonts = {
      serif = {
        package = pkgs.nerdfonts;
        name = "Noto Serif";
      };
      sansSerif = {
        package = pkgs.nerdfonts;
        name = "Noto Sans";
      };
      monospace = {
        package = pkgs.nerdfonts;
        name = "JetBrainsMono";
      };
    };
  };

  system.stateVersion = "24.05";
}
