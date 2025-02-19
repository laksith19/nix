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
      bat
      lsd
      fastfetch
      wget
      wget2
      dnsutils
      traceroute
      python3Full

      # GUI - sway
      grim # Screenshot
      slurp # Screenshot
      wl-clipboard # Clipboard
      mako # Notifications
      waybar # bar
      wofi # launcher
      bitwarden-desktop # password manager
      virt-viewer

      # Wayland Firefox with screen-sharing support
      pavucontrol # Audio control
      pulseaudio # Get access to pactl for volumekeys
      wdisplays # Monitors config
      vlc # cause you need it you dummy
      abiword # word processor
      signal-desktop # well this u need i guess
      discord # and this...
      remmina # VNC
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
      tree = "${lib.getExe pkgs.lsd} --tree";
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

      opts = {
        compatible = false; # Disable Vi compatibility mode
        showmatch = true; # Show matching brackets when cursor is over one
        ignorecase = true; # Case-insensitive search
        mouse = "a"; # Enable mouse support in all modes
        hlsearch = true; # Highlight search results
        incsearch = true; # Enable incremental search

        # Tab and indentation settings
        tabstop = 2; # Number of spaces per tab
        softtabstop = 2; # Spaces per tab when hitting <BS>
        expandtab = true; # Convert tabs to spaces
        shiftwidth = 2; # Number of spaces for autoindent
        autoindent = true; # Maintain indent level of previous line

        number = true; # Show line numbers
        wildmode = ["longest" "list"]; # Bash-like tab completion behavior

        clipboard = "unnamedplus"; # Use system clipboard for copy/paste
        cursorline = true; # Highlight the current cursor line
        linebreak = true; # Break lines at word boundaries
        breakindent = true; # Indent wrapped lines visually
        ttyfast = true; # Optimize performance for fast terminals
      };


      plugins = {
        treesitter.enable = true; # Syntax-aware highlighting
        telescope.enable = true; # Fuzzy finder
        lualine.enable = true; # Statusline
        which-key.enable = true; # Keybinding hints

        # Autocomplete Plugins
        cmp.enable = true;
        cmp-nvim-lsp.enable = true;
        cmp-buffer.enable = true;
        cmp-path.enable = true;
        cmp-cmdline.enable = true;
        luasnip.enable = true;
        cmp_luasnip.enable = true;
        
        lsp = {
          enable = true;
          servers = {
            nixd.enable = true;
            pyright.enable = true;
          };
        };
      };

      # Lua config for nvim-cmp
      extraConfigLua = ''

        vim.cmd("filetype plugin indent on")
        vim.cmd("syntax on")

        local cmp = require("cmp")
        local luasnip = require("luasnip")

        cmp.setup({
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            ["<Tab>"] = function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              else
                fallback()
              end
            end,
            ["<S-Tab>"] = function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end,
          }),
          sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "luasnip" },
            { name = "buffer" },
            { name = "path" },
          }),
        })

        -- Autocomplete in command mode
        cmp.setup.cmdline(":", {
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources({
            { name = "path" },
            { name = "cmdline" },
          }),
        })
      '';

      extraPackages = with pkgs; [
        nixd
        pyright
      ];
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
    printing.enable = true;

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

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
