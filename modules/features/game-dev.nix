{ ... }: {
  flake.nixosModules.game-dev = { pkgs, ... }: {

    home-manager.users.brandon = {
      home.packages = with pkgs; [
        blender
        godot
        inkscape
        itch
      ];
    };

  };
}
