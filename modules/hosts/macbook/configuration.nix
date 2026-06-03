{ ... }: {
  flake.darwinModules.macbookConfiguration = { pkgs, ... }: {

    nixpkgs.hostPlatform = "aarch64-darwin";

    users.users.brandon = {
      home = "/Users/brandon";
      shell = pkgs.zsh;
    };

    programs.zsh.enable = true;
    environment.systemPackages = [ ];

    system.stateVersion = 5;

    _module.args = {
      syncthingName = "macbook";
    };

    # Let Determinate Systems manage this
    nix.enable = false;
  };
}
