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
				mongodb-compass
				vi-mongo # TUI Mongo Editor
      ];
    };

  };
in {
  flake.nixosModules.work = workModule;
  flake.darwinModules.work = workModule;
}

