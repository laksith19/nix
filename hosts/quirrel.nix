{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../hardware/thinkpad.nix
  ];

  nix = {
    channel.enable = false;
    settings.experimental-features = ["nix-command" "flakes"];
  };

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

    kernelParams = ["console=tty1"];

    binfmt.emulatedSystems = ["aarch64-linux"];

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
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.laksith = import ../homes/laksith.nix;
  };

  environment = {
    systemPackages = with pkgs; [
      # Utils
      ripgrep

      # GUI - sway
      grim # Screenshot
      slurp # Screenshot
      wl-clipboard # Clipboard
      mako # Notifications
      waybar # bar
      wofi # launcher
      bitwarden-desktop # password manager
      spice-gtk

      # Wayland Firefox with screen-sharing support
      pavucontrol # Audio control
      pulseaudio # Get access to pactl for volumekeys
      wdisplays # Monitors config
      vlc # cause you need it you dummy
      abiword # word processor
      signal-desktop # well this u need i guess
      discord # and this...
      remmina # VNC / SPICE client

      zoom-us # Zoom meetings client
    ];
    sessionVariables = {
      XDG_CURRENT_DESKTOP = "sway";
      XDG_SESSION_TYPE = "wayland";
    };
    shellAliases = {
      wget = "${lib.getExe pkgs.wget2}";
      neofetch = "${lib.getExe pkgs.fastfetch}";
      ls = "${lib.getExe pkgs.lsd}";
      cat = "${lib.getExe pkgs.bat}";
    };
  };

  programs = {
    tmux.enable = true;
    git.enable = true;
    htop.enable = true;
    seahorse.enable = true;
    light.enable = true;
    thunar.enable = true;
    nm-applet.enable = true;
    nix-index-database.comma.enable = true;

    starship = {
      enable = true;
      presets = ["nerd-font-symbols"];
    };

    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    firefox = {
      enable = true;
      wrapperConfig = {
        pipewireSupport = true;
      };
    };

    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };

    fzf = {
      keybindings = true;
      fuzzyCompletion = true;
    };

    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    nixvim = {
      enable = true;
      viAlias = true;
      vimAlias = true;

      colorschemes.catppuccin = {
        enable = true;
        settings.flavour = "macchiato";
      };

      #TODO: Hacky way to just use current config but nix it in the future
      extraConfigVim = ''
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

  # Nerd fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["JetBrainsMono" "Noto"];})
  ];

  security = {
    # Unlock on login ... hmmm this doesn't seem to work properly
    pam.services."laksith".enableGnomeKeyring = true;
    rtkit.enable = true;
    polkit.enable = true;
  };

  services = {
    gnome.gnome-keyring.enable = true;
    hardware.bolt.enable = true;
    blueman.enable = true;
    fwupd.enable = true;
    fprintd.enable = true;

    greetd = {
      enable = true;
      vt = 2;

      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
          user = "greeter";
        };
      };
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };

  virtualisation = {
    docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };

    waydroid.enable = true;
  };

  stylix = {
    enable = true;
    image = ../assets/wallpaper.png;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";

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
