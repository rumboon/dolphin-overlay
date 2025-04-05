# Dolphin Open With Menu Fix

This Nix overlay fixes Dolphin's "Open with" menu when running outside of KDE (e.g., under Hyprland or other Wayland compositors).

## Issues Resolved

### 1. Missing Menu Configuration
- Dolphin relies on KDE's KService framework to populate its "Open with" menu
- Without KDE, the menu configuration file (`applications.menu`) is not found
- This overlay sets the correct `XDG_CONFIG_DIRS` to include the Qt5 KService which does include the `applications.menu`

### 2. Stale Service Cache
- Dolphin uses KDE's service cache (ksycoca) to find available applications
- Without KDE, the cache is not properly built or updated
- This overlay runs `kbuildsycoca6 --noincremental` before Dolphin starts to ensure the cache is up-to-date with the correct menu configuration by using the Qt5 KService resources

## Usage

1. Choose one of the following methods to add the overlay:

### Option A: Using Flakes
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    dolphin-overlay.url = "github:rumboon/dolphin-overlay";
  };

  outputs = { self, nixpkgs, dolphin-overlay, ... }: {
    nixosConfigurations.your-host = nixpkgs.lib.nixosSystem {
      modules = [
        {
          nixpkgs.overlays = [ dolphin-overlay.overlays.default ];
        }
      ];
    };
  };
}
```

### Option B: Without Flakes
Clone this repository and add to your NixOS configuration:
```nix
{ config, pkgs, ... }:
{
  nixpkgs.overlays = [
    (import /path/to/dolphin-overlay/default.nix)
  ];
}
```

2. Rebuild your system:
```bash
sudo nixos-rebuild switch
```

## How It Works

The overlay modifies the Dolphin package by:
1. Setting the correct `XDG_CONFIG_DIRS` environment variable
2. Rebuilding the KDE service cache before launching Dolphin

This approach is non-intrusive as it only affects the dolphin package and does not modify global environment variables or system-wide configurations.

## Benefits

- Properly populated "Open with" menu in Dolphin
- Works without a full KDE installation
- No global environment modifications
- Automatic cache rebuilding on launch