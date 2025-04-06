{
  config,
  pkgs,
  lib,
  ...
}: {
  home = {
    username = "laksith";
    homeDirectory = "/home/laksith";
    stateVersion = "24.05";
    file = {
      ".ssh/allowed_signers".text = lib.strings.concatStringsSep "\n" [
        "<admin@laksith.dev> ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO6zftyMUeIQVYkRag6CxWqYShjWnErQ24NeaU95Bp2z laksith@quirrel"
        "<admin@laksith.dev> ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB1k8sWCp4/J+uw5RFHQ0UrVJpxK7fExlJlALNsHehs8 laksith@tsunami"
      ];
    };
    packages = with pkgs; [
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

      # utils
      pandoc
      shellcheck
      bashate
      git-branchless
      shfmt
      bash-language-server
      hadolint # Docker linting
      dockerfile-language-server-nodejs
      ispell

      # Rust
      cargo
      rustc
      cargo-edit
      cargo-outdated
      rustfmt
      clippy
      rust-analyzer
    ];
  };

  programs = {
    home-manager.enable = true;
    waybar.enable = true;
    bat.enable = true;
    wofi.enable = true;
    bash.enable = true;
    starship.enable = true;
    gh.enable = true;
    emacs.enable = true;

    ssh = {
      enable = true;
      matchBlocks = {
        global = {
          host = "*";
          setEnv = {TERM = "xterm-256color";};
          serverAliveInterval = 60;
          forwardAgent = false;
        };

        beacon-master = {
          host = "beacon-master";
          hostname = "138.68.246.148";
          user = "root";
        };

        soda = {
          host = "soda";
          hostname = "soda.berkeley.edu";
          user = "Laksith";
        };

        elderbug = {
          host = "elderbug";
          hostname = "10.8.0.4";
          serverAliveInterval = 10;
        };

        pve-tunnel = {
          host = "pve-tunnel";
          hostname = "192.168.1.2";
          user = "root";
          serverAliveInterval = 10;
          serverAliveCountMax = 3;
          localForwards = [
            {
              bind.address = "localhost";
              bind.port = 8006;
              host.address = "localhost";
              host.port = 8006;
            }
            {
              bind.address = "localhost";
              bind.port = 3128;
              host.address = "localhost";
              host.port = 3128;
            }
          ];
          extraOptions = {ExitOnForwardFailure = "yes";};
          proxyJump = "elderbug";
        };

        cornifer = {
          host = "cornifer";
          hostname = "192.168.0.27";
          proxyJump = "elderbug";
        };

        tsunami = {
          host = "tsunami";
          hostname = "tsunami.ocf.berkeley.edu";
          user = "laksith";
        };

        supernova = {
          host = "supernova";
          hostname = "supernova.ocf.berkeley.edu";
        };

        decal = {
          host = "decal";
          hostname = "tsunami.ocf.berkeley.edu";
          user = "decal";
        };

        hornet = {
          host = "hornet";
          hostname = "10.8.0.2";
        };

        cs61bl = {
          host = "cs61bl";
          hostname = "cory.eecs.berkeley.edu";
          user = "cs61bl";
          proxyJump = "cs61bl@eecs-bastion";
        };

        eecs-bastion = {
          host = "eecs-bastion";
          hostname = "instgw.eecs.berkeley.edu";
        };

        cs199 = {
          host = "cs199";
          hostname = "cory.eecs.berkeley.edu";
          user = "cs199-cmx";
          proxyJump = "cs199-cmx@eecs-bastion";
        };

        grimm = {
          host = "grimm";
          hostname = "192.168.1.6";
          user = "laksith";
          proxyJump = "elderbug";
        };

        jellyfin = {
          host = "jellyfin";
          hostname = "192.168.1.6";
          user = "laksith";
          proxyJump = "elderbug";
        };

        whitelady = {
          host = "whitelady";
          hostname = "192.168.1.112";
          user = "laksith";
          proxyJump = "elderbug";
        };

        git = {
          host = "git";
          hostname = "192.168.1.112";
          port = 222;
          user = "git";
          proxyJump = "elderbug";
        };

        ocftv = {
          host = "ocftv";
          hostname = "tornado.ocf.berkeley.edu";
          proxyJump = "supernova";
        };

        ocf-proxy-jump = {
          host = "*.ocf.berkeley.edu *.ocf.io !supernova.ocf.io !supernova.ocf.berkeley.edu";
          proxyJump = "supernova";
        };
      };
    };

    kitty = {
      enable = true;
      themeFile = "Catppuccin-Macchiato";
      font = {
        name = "JetBrainsMono NF";
        size = 12;
      };
    };

    git = {
      enable = true;
      userName = "laksith19";
      userEmail = "admin@laksith.dev";
      extraConfig = {
        commit.gpgsign = true;
        gpg.format = "ssh";
        gpg.ssh.allowedsignersfile = "${toString config.home.homeDirectory}/.ssh/allowed_signers";
        user.signingkey = "${toString config.home.homeDirectory}/.ssh/id_ed25519.pub";
        init.defaultbranch = "main";
      };
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4";
      terminal = "${lib.getExe pkgs.kitty}";

      defaultWorkspace = "workspace number 1";

      menu = "'${lib.getExe pkgs.wofi} --show drun | ${lib.getExe' pkgs.findutils "xargs"} ${lib.getExe' pkgs.sway "swaymsg"}'";

      window = {
        titlebar = false;
        border = 0;
      };

      gaps = {
        smartBorders = "on";
        smartGaps = true;
        inner = 2;
        outer = -2;
        top = 2;
        bottom = 2;
      };

      bars = [
        {
          command = "${lib.getExe pkgs.waybar}";
          position = "top";
        }
      ];

      keybindings = lib.mkOptionDefault {
        # Brightness
        "XF86MonBrightnessDown" = "exec ${lib.getExe pkgs.light} -U 10";
        "XF86MonBrightnessUp" = "exec ${lib.getExe pkgs.light} -A 10";

        # Volume
        "XF86AudioRaiseVolume" = "exec '${lib.getExe' pkgs.pulseaudio "pactl"} set-sink-volume @DEFAULT_SINK@ +1%'";
        "XF86AudioLowerVolume" = "exec '${lib.getExe' pkgs.pulseaudio "pactl"} set-sink-volume @DEFAULT_SINK@ -1%'";
        "XF86AudioMute" = "exec '${lib.getExe' pkgs.pulseaudio "pactl"} set-sink-mute @DEFAULT_SINK@ toggle'";
        # Mic
        "XF86AudioMicMute" = "exec '${lib.getExe' pkgs.pulseaudio "pactl"} set-source-mute @DEFAULT_SINK@ toggle'";

        # Screenshot
        "Print" = "exec 'GRIM_DEFAULT_DIR=${toString config.home.homeDirectory}/Pictures/Screenshots ${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp})\"'";
      };

      input = {
        "type:touchpad" = {
          dwt = "enabled";
          dwtp = "enabled";
          tap = "enabled";
          tap_button_map = "lrm";
          pointer_accel = "0.2";
          natural_scroll = "enabled";
        };
      };

      output = {
        "*" = {
          bg = "${builtins.path {path = ../assets/wallpaper.png;}} fill";
        };
      };
    };
  };

  services = {
    network-manager-applet.enable = true;
    ssh-agent.enable = true;

    mako = {
      enable = true;
      defaultTimeout = 5000; # milliseconds
    };
  };
}
