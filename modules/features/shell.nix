{ ... }:

let
  shellModule = { pkgs, ... }: {

    home-manager.users.brandon = {
      home.packages = with pkgs; [
        fastfetch
        nerd-fonts.jetbrains-mono
        fd
        ripgrep
      ];

      programs.zsh = {
        enable = true;
        initContent = ''
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

      programs.starship = {
        enable = true;
        settings = {
          add_newline = true;
          format = "[ ](bg:#3b4252 fg:#2e3440)[ ](bg:#434c5e fg:#3b4252)[ ](bg:#88c0d0 fg:#434c5e)[󱄅 ](bg:#88c0d0 fg:#434c5e)[ ](bg:#81a1c1 fg:#88c0d0)[$directory](bg:#81a1c1 fg:#000000)[ ](bg:#81a1c1 fg:#81a1c1)[ ](fg:#81a1c1)\n";
          directory = {
            style = "fg:#434c5e bg:#81a1c1";
            format = "[ $path ]($style)";
            truncation_length = 3;
            truncation_symbol = ".../";
          };
        };
      };

      programs.tmux = {
        enable = true;
        prefix = "C-Space";
        baseIndex = 1;
        terminal = "tmux-256color";
        mouse = true;
        plugins = with pkgs.tmuxPlugins; [
          nord
          vim-tmux-navigator
        ];
        extraConfig = ''
          bind-key P display-popup -w 80% -h 80% -E
          set -g pane-border-lines double

          bind -r Left resize-pane -L 10
          bind -r Right resize-pane -R 10
          bind -r Up resize-pane -U 10
          bind -r Down resize-pane -D 10
          set -g repeat-time 700
        '';
      };

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false; # This is deprecated, so setting to false now to get ahead
        settings = {
          "github.com" = {
            identityFile = "~/.ssh/id_ed25519";
            user = "git";
          };
          "*" = {
            forwardAgent = false;
            addKeysToAgent = "no";
            compression = false;
            serverAliveInterval = 0;
            serverAliveCountMax = 3;
            hashKnownHosts = false;
            userKnownHostsFile = "~/.ssh/known_hosts";
            controlMaster = "no";
            controlPath = "~/.ssh/master-%r@%n:%p";
            controlPersist = "no";
          };
        };
      };

      programs.kitty = {
        enable = true;
        themeFile = "Nord";
        settings = {
          clipboard_control = "write-clipboard write-primary read-clipboard read-primary";
          allow_hyperlinks = "yes";
        };
        font = {
          name = "JetBrainsMono Nerd Font";
          size = 12;
        };
      };
    };
  };
in {
  flake.nixosModules.shell = shellModule;
  flake.darwinModules.shell = shellModule;
}

