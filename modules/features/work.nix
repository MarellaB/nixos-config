{ ... }:

let
  workModule = { pkgs, ... }: {

    # Used for VPN into the office
    environment.systemPackages = with pkgs; [
      strongswan
      openssl
    ];

    services.strongswan-swanctl.enable = true;

    home-manager.users.brandon = {
      home.packages = with pkgs; [
        (with pkgs.dotnetCorePackages; combinePackages [
          sdk_8_0
          sdk_10_0
        ])
        # roslyn-ls
        csharp-ls

        mongosh
        vi-mongo # TUI Mongo Editor
        teams-for-linux
        libreoffice
      ];
    };

  };
in {
  flake.nixosModules.work = workModule;
  flake.darwinModules.work = workModule;
}

