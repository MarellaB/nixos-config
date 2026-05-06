{ self, inputs, ... }:

let
  shellModule = { pkgs, ... }: {

    home-manager.users.brandon = {
			home.packages = with pkgs; [
				nerd-fonts.jetbrains-mono
			];

      programs.zsh = {
        enable = true;
        initExtra = ''
          rebuild() {
            local host=''${1:-desktop}
            local extra_args=''${@:2}

            if [[ "$(uname)" == "Darwin" ]]; then
              sudo darwin-rebuild switch --flake ~/nixos-config#macbook $extra_args
            else
              sudo nixos-rebuild switch --flake ~/nixos-config#$host $extra_args
            fi
          }
        '';
      };

      programs.kitty = {
        enable = true;
				themeFile = "Nord";
				font = {
					name = "JetBrainsMono Nerd Font Mono";
					size = 12;
				};
      };
    };
  };
in {
  flake.nixosModules.shell = shellModule;
  flake.darwinModules.shell = shellModule;
}

