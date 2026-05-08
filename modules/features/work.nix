{ self, ... }:

let
  workModule = { pkgs, ... }: {

    home-manager.users.brandon = {
      home.packages = with pkgs; [
				nodejs
				dotnet-sdk
				mongosh
      ];
    };

  };
in {
  flake.nixosModules.work = workModule;
  flake.darwinModules.work = workModule;
}

