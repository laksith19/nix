{ pkgs, ...}: 

# Wrap the spotify package to use wayland by default
pkgs.symlinkJoin {
  name = "spotify";
  paths = [ pkgs.spotify ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/spotify \
      --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
  '';
}


