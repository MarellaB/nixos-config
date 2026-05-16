{ self, ... }:

let
  devModule = { pkgs, ... }: {

    home-manager.users.brandon = {
      home.packages = with pkgs; [
        gcc
        lazygit
				lazydocker
				opencode
				claude-code
				pnpm
				emacs
        
        self.packages.${pkgs.stdenv.hostPlatform.system}.neovim
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

