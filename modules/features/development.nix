{ self, ... }:

let
  devModule = { pkgs, config, ... }:
  let
			isDesktop = config.networking.hostName == "brandons-nixos-desktop";
      isWorkLaptop = config.networking.hostName == "brandon-marellas-work-laptop";
  in {

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
        nodejs

        nixd

        rustc
        cargo
        rust-analyzer

        self.packages.${pkgs.stdenv.hostPlatform.system}.neovim
        libvterm-neovim

        typescript-language-server
        #vtsls
        svelte-language-server
        typescript
        tailwindcss-language-server
        eslint
      ];

      programs.emacs = {
        enable = true;
        package = pkgs.emacs30;
        extraPackages = epkgs: [
          epkgs.treesit-grammars.with-all-grammars
        ];
      };
      home.file.".local/share/treesit-grammars".source =
        pkgs.symlinkJoin {
        name = "treesit-grammars";
        paths = [ (pkgs.emacsPackagesFor pkgs.emacs30).treesit-grammars.with-all-grammars ];
      };
        home.sessionVariables = {
            TREESIT_GRAMMAR_PATH = "/nix/store/w5sc6jbv18w9jgl5idzavci01jl0sws1-emacs-packages-deps/lib";
        };

      programs.git = {
        enable = true;
        ignores = [
          ".dir-locals.el"
          "TODO.md"
        ];

        settings = {
          init.defaultBranch = "main";
          pull.rebase = false;
					core.autocrlf = "input";
					user = {
						name = if isDesktop then "Brandon" else "Brandon Marella";
						email = if isDesktop then "brandonmarella@gmail.com" else "bmarella@dolbey.com";
					};
        };
      };

    };

  };
in {
  flake.nixosModules.development = devModule;
  flake.darwinModules.development = devModule;
}

