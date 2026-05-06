{ self, inputs, ... }:

let
  devModule = { pkgs, ... }: {

    home-manager.users.brandon = {
      home.packages = with pkgs; [
        gcc
        lazygit
        
        # LSPs
        lua-language-server
        marksman
        taplo
        shfmt
        hadolint
        tree-sitter

        self.packages.${pkgs.system}.neovim
      ];

      programs.git = {
        enable = true;
        settings = {
          user = {
            name = "Brandon";
            email = "brandonmarella@gmail.com";
          };
          init.defaultBranch = "main";
          pull.rebase = false;
        };
      };
    };

  };
in {
  flake.nixosModules.development = devModule;
  flake.darwinModules.development = devModule;
}

