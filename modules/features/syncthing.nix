{ config, pkgs, lib, syncthingName, ... }:

let
  # 1. Define all device IDs in a central mapping
  allDevices = {
    "wrench"   = "H2DVO6J-3K3SJ7H-CMI6VOM-3ZBRSYE-JNWJJ4K-PYEYJSP-HVRRLNZ-QTQTDQ6";
    "desktop"  = "ATKS73R-C236PU6-W6EGJOS-OVM4FRG-VHIAWF5-3F4QEBK-VTJKR7N-DG2XXAD";
    "work-laptop"   = "PASTE_YOUR_LAPTOP_ID_TOMORROW_HERE";
    "macbook"  = "PASTE_YOUR_MACBOOK_ID_HERE";
  };

  # 2. Automatically detect if this is a Mac or a Linux machine to set the correct home path
  isDarwin = pkgs.stdenv.isDarwin;
  homeDir  = if isDarwin then "/Users/brandon" else "/home/brandon";

  # 3. Dynamic helper: Get all devices EXCEPT the one we are currently configuring
  # (Requires setting networking.hostName in the respective machine configurations)
  currentHost = config.networking.hostName;
  otherDevices = lib.filterAttrs (name: _: name != syncthingName) allDevices;

  # Map those names to the structure Syncthing expects
  targetDevices = lib.mapAttrs (name: id: { inherit id; }) otherDevices;
in
{
  services.syncthing = {
    enable = true;
    user = "brandon";
    dataDir = homeDir;
    configDir = "${homeDir}/.config/syncthing";

    overrideDevices = true;
    overrideFolders = true;
    guiAddress = "127.0.0.1:8384";

    # Injects only the remote devices into this specific machine
    settings.devices = targetDevices;

    settings.folders = {
      "documents-sync" = {
        path = "${homeDir}/sync";
        # Automatically syncs with every other device in your pool
        devices = builtins.attrNames targetDevices;
      };
      "orgmode-sync" = {
        path = "${homeDir}/org";
        devices = builtins.attrNames targetDevices;
        versioning = {
          type = "simple";
          params.keep = "5";
        };
      };
    };
  };
}
