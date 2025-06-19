{
  lib,
  pkgs,
  catppuccin,
  ...
}: {
  imports = [
    ../hardware/thinkpad.nix
  ];

  nix = {
    channel.enable = false;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "America/Los_Angeles";

  hardware = {
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
    enableRedistributableFirmware = true;
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
      extraGroups = ["libvirtd" "networkmanager" "wheel" "video" "wireshark"];
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.laksith.imports = [
      ../homes/laksith.nix
      catppuccin.homeModules.catppuccin
    ];
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
    light.enable = true;
    seahorse.enable = true;
    nm-applet.enable = true;
    nix-index-database.comma.enable = true;
    gnupg.agent.enable = true;
    virt-manager.enable = true;

    starship = {
      enable = true;
      presets = ["nerd-font-symbols"];
    };

    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    # Wayland firefox with screen sharing support
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

    nixvim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;

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
        web-devicons.enable = true;
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
    rtkit.enable = true;
    polkit.enable = true;
  };

  services = {
    gnome.core-apps.enable = true;
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
    libvirtd.enable = true;
    libvirtd.qemu.swtpm.enable = true;
    spiceUSBRedirection.enable = true;
    docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };

    waydroid.enable = true;
  };

  # TODO: Potentially upstream this as it's silly to not have socket activated userspace docker
  systemd.user.services.docker = {
    wantedBy = lib.mkForce [];
    after = ["docker.socket"];
  };

  systemd.user.sockets.docker = {
    description = "Rootless-Docker Socket";
    wantedBy = ["sockets.target"];
    listenStreams = ["%t/docker.sock"];
  };

  system.stateVersion = "24.05";
}
