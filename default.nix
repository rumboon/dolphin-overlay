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
  kdePackages = prev.kdePackages.overrideScope (kfinal: kprev: {
    dolphin = kprev.dolphin.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ prev.makeWrapper ];
      postInstall = (oldAttrs.postInstall or "") + ''
        wrapProgram $out/bin/dolphin \
            --set XDG_CONFIG_DIRS "${prev.libsForQt5.kservice}/etc/xdg:$XDG_CONFIG_DIRS" \
            --run "${kprev.kservice}/bin/kbuildsycoca6 --noincremental ${prev.libsForQt5.kservice}/etc/xdg/menus/applications.menu"
      '';
    });
  });
}
