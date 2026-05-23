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
        gnumake
        cmake

        rustc
        cargo
        
        self.packages.${pkgs.stdenv.hostPlatform.system}.neovim
        libvterm-neovim

        typescript-language-server
        svelte-language-server
        typescript
        tailwindcss-language-server
      ];

			programs.emacs = {
				enable = true;
				package = pkgs.emacs30-pgtk;
      };

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

