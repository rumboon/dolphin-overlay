# This Nix overlay modifies the Dolphin file manager package (GPL-licensed)
# to fix its "Open with" menu functionality when running outside of KDE.
# 
# This overlay is provided as-is and is intended for personal use or as a
# contribution to Nixpkgs. It is compatible with the GPL license of Dolphin.
# 
# Copyright (c) 2025 rumboon
# This overlay is licensed under the terms of the MIT license.
# 
# The modified package retains its original GPL license.

final: prev: {
  kdePackages = prev.kdePackages.overrideScope (
    kfinal: kprev:
    let
      kservice5Menu = prev.stdenv.mkDerivation {
        name = "kservice5-applications-menu";
        version = "5.116.0";

        src = prev.fetchFromGitLab {
          domain = "invent.kde.org";
          owner = "frameworks";
          repo = "kservice";
          tag = "v5.116.0";
          sparseCheckout = [ "src/applications.menu" ];
          hash = "sha256-28ueuJiI34o1wayiq85KPNkUCwjdhPMYtU2nJTQ84V4=";
        };

        installPhase = ''
          mkdir -p $out/etc/xdg/menus
          cp ./src/applications.menu $out/etc/xdg/menus/applications.menu
        '';
      };
    in
    {
      dolphin = prev.symlinkJoin {
        name = "dolphin-wrapped";
        paths = [ kprev.dolphin ];
        nativeBuildInputs = [ prev.makeWrapper ];
        postBuild = ''
          rm $out/bin/dolphin
          makeWrapper ${kprev.dolphin}/bin/dolphin $out/bin/dolphin \
            --set XDG_CONFIG_DIRS "${kservice5Menu}/etc/xdg:$XDG_CONFIG_DIRS" \
            --run "${kprev.kservice}/bin/kbuildsycoca6 --noincremental ${kservice5Menu}/etc/xdg/menus/applications.menu"
        '';
      };
    }
  );
}
