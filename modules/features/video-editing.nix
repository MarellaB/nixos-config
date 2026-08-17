
{ ... }: {
  flake.nixosModules.videoEditing = { pkgs, ... }: {
    home-manager.users.brandon = {
      home.packages = with pkgs; [
        kdePackages.kdenlive
        obs-studio
      ];
    };
  };
}
