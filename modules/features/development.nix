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
          init.defaultBranch = "main";
          pull.rebase = false;
					core.autocrlf = isWorkLaptop;
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

