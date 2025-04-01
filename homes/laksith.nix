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

    mako = {
      enable = true;
      defaultTimeout = 5000; # milliseconds
    };
  };
}
