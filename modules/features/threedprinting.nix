{ ... }: {
  flake.nixosModules.threedprinting = { pkgs, ... }: {

    home-manager.users.brandon = {
      home.packages = with pkgs; [
        freecad
        orca-slicer
      ];
    };

  };
}
