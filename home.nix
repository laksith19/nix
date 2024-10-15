{ config, pkgs, ... }:

{
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
  programs.rofi.enable = true;
  programs.waybar.enable = true;
  programs.vim.enable = true;
  programs.bat.enable = true;
  wayland.windowManager.sway  = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      terminal = "kitty";
    };

}

