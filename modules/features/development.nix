{ self, inputs, ... }: {
  flake.nixosModules.development = { pkgs, ... }: {

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
      withRuby = false;
      withPython3 = false;
    };

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

      xdg.configFile."nvim" = {
        source = ./nvim;
        recursive = true;
      };
      xdg.configFile."nvim/lazy-lock.json".enable = false;
    };

  };
}
