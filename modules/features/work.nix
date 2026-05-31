{ ... }:

let
  workModule = { pkgs, ... }: {

    home-manager.users.brandon = {
      home.packages = with pkgs; [
        nodejs
        (with pkgs.dotnetCorePackages; combinePackages [
          sdk_8_0
          sdk_10_0
        ])
        mongosh
        vi-mongo # TUI Mongo Editor
        teams-for-linux
      ];
    };

  };
in {
  flake.nixosModules.work = workModule;
  flake.darwinModules.work = workModule;
}

