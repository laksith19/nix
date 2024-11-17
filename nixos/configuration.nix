# Laksith's NixOS Config
# Primarily used on quirrel (primary laptop)
{
  config,
  pkgs,
  pkgs-unstable,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-4dd038a9-c121-4b7b-b4fe-a0a65a6b81ea".device = "/dev/disk/by-uuid/4dd038a9-c121-4b7b-b4fe-a0a65a6b81ea";
  networking.hostName = "quirrel"; # Define your hostname.

  # Disable Systemd Networkd (not the best for laptops)
  systemd.network.enable = false;
  # Enable network manager
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users = {
    users.laksith = {
      isNormalUser = true;
      description = "laksith";
      extraGroups = ["networkmanager" "wheel" "video" "wireshark"];
      packages = with pkgs; [
      zoom-us
      pkgs-unstable.zed-editor
      ];
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Use nix-flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
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
  ];

  # Enable wireshark-cli as well and make appropriate usergroups
  programs.wireshark.enable = true;

  # Install Steam
  programs.steam.enable = true;

  # NeoVim Installation and config
  programs.neovim = {
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

  # Nerd fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["JetBrainsMono"];})
  ];

  # Enable gnome-keyring for sway
  services.gnome.gnome-keyring.enable = true;

  # Greeter - greetd
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
        user = "greeter";
      };
    };
  };

  # Thunderbolt support
  services.hardware.bolt.enable = true;

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Home Manager Sway Support
  security.polkit.enable = true;

  # Bluetooth support
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Enable 32-bit support
  hardware.amdgpu.amdvlk.support32Bit.enable = true;

  # Enable sway
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # brightness
  programs.light.enable = true;

  # PGP
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Currently using a manually imported network manager vpn
  networking.firewall.allowedUDPPorts = [
    51820 # Wireguard client
  ];

  # Enable Rootless docker
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_TYPE = "wayland";
  };

  # kanshi systemd service
  # systemd.user.services.kanshi = {
  #   description = "kanshi daemon";
  #   serviceConfig = {
  #     Type = "simple";
  #     ExecStart = ''${pkgs.kanshi}/bin/kanshi -c kanshi_config_file'';
  #   };
  # };

  # stylix
  stylix = {
    enable = true;
    image = ./wallpaper.png;
    polarity = "dark";

    fonts = {
      serif = {
        package = pkgs.nerdfonts;
        name = "DejaVu Serif";
      };
      sansSerif = {
        package = pkgs.nerdfonts;
        name = "DejaVu Sans";
      };
      monospace = {
        package = pkgs.nerdfonts;
        name = "JetBrainsMono";
      };
    };
  };

  system.stateVersion = "24.05";
}
