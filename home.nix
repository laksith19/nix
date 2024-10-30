{
  config,
  pkgs,
  lib,
  ...
}: {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "laksith";
  home.homeDirectory = "/home/laksith";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.kitty.enable = true;

  # Use the wayland version
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
  };

  programs.waybar.enable = true;
  programs.vim.enable = true;
  programs.bat.enable = true;

  home.file.".ssh/allowed_signers".text = "<admin@laksith.dev> 
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO6zftyMUeIQVYkRag6CxWqYShjWnErQ24NeaU95Bp2z laksith@quirrel";
  programs.git = {
    enable = true;
    userName = "laksith19";
    userEmail = "admin@laksith.dev";

    extraConfig = {
      commit.gpgsign = true;
      gpg.format = "ssh";
      gpg.ssh.allowedsignersfile = "~/.ssh/allowed_signers";
      user.signingkey = "~/.ssh/id_ed25519.pub";
      init.defaultbranch = "main";
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      terminal = "kitty";

      defaultWorkspace = "workspace number 1";

      menu = "'rofi -show combi | swaymsg'";

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
          command = "waybar";
          position = "top";
        }
      ];

      keybindings = lib.mkOptionDefault {
        # Brightness
        "XF86MonBrightnessDown" = "exec light -U 10";
        "XF86MonBrightnessUp" = "exec light -A 10";

        # Volume
        "XF86AudioRaiseVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ +1%'";
        "XF86AudioLowerVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ -1%'";
        "XF86AudioMute" = "exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'";
        # Mic
        "XF86AudioMicMute" = "exec 'pactl set-source-mute @DEFAULT_SINK@ toggle'";

        # Screenshot
        "Print" = "exec 'GRIM_DEFAULT_DIR=~/Pictures/Screenshots grim -g \"$(slurp)\"'";
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
    };
  };
  services.network-manager-applet.enable = true;
  services.mako.enable = true;
}
