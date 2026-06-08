{ ... }:

let
  shellModule = { pkgs, ... }: {

    home-manager.users.brandon = {
      home.packages = with pkgs; [
        fastfetch
        nerd-fonts.jetbrains-mono
        fd
        ripgrep
        btop
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
          format = ''
            [ ](bg:#282a2e fg:#1d1f21)[ ](bg:#373b41 fg:#282a2e)[ ](bg:#c5c8c6 fg:#373b41)[󱄅 ](bg:#c5c8c6 fg:#1d1f21)[ ](bg:#282a2e fg:#c5c8c6)$directory$git_branch$git_status$nix_shell$golang$nodejs$rust$cmd_duration
            $character'';

            directory = {
              style = "fg:#ffffff bg:#282a2e bold";
              format = "[$path ]($style)[](fg:#282a2e)";
              truncation_length = 3;
              truncation_symbol = ".../";
            };

            git_branch = {
              style = "fg:#c5c8c6 bold";
              format = "[  $branch]($style)";
            };

            # Git Status: Strictly ahead/behind. No other tracking keys defined so they can't render.
            git_status = {
              style = "fg:#de935f bold";
              format = "[ $ahead_behind]($style)"; # Sits tight next to the branch text
              ahead = "Ahead";
              behind = "Behind";
            };

            # LANGUAGE AND SYSTEM MODULES
            nix_shell = {
              style = "fg:#c5c8c6 bold";
              symbol = " ";
              format = "[  $symbol$name]($style)";
            };

            golang = {
              style = "fg:#c5c8c6 bold";
              symbol = " ";
              format = "[  $symbol$version]($style)";
            };

            nodejs = {
              style = "fg:#c5c8c6 bold";
              symbol = " ";
              format = "[  $symbol$version]($style)";
            };

            rust = {
              style = "fg:#c5c8c6 bold";
              symbol = " ";
              format = "[  $symbol$version]($style)";
            };

            cmd_duration = {
              min_time = 2000;
              style = "fg:#969896";
              format = "[  󱎫 $duration]($style)";
            };

            character = {
              success_symbol = "[❯](fg:#ffffff bold)";
              error_symbol = "[❯](fg:#cc6666 bold)";
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

          # --- Tomorrow Night Colors ---
          set -g status-style "bg=#282a2e,fg=#c5c8c6"
          set -g pane-border-style "fg=#373b41"
          set -g pane-active-border-style "fg=#81a2be"
          set -g mode-style "bg=#373b41,fg=#c5c8c6"
          set -g message-style "bg=#282a2e,fg=#c5c8c6"

          # Inactive tabs: Subtle gray on dark background
          set -g window-status-style "bg=#282a2e,fg=#969896"
          set -g window-status-format " #I:#W "

          # Active tab: High-contrast white/light-gray text on a slightly lighter charcoal block
          set -g window-status-current-style "bg=#373b41,fg=#ffffff,bold"
          set -g window-status-current-format " #I:#W* "

          # Thin separator between tabs to keep it clean
          set -g window-status-separator ""
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
        themeFile = "Tomorrow_Night";
        settings = {
          clipboard_control = "write-clipboard write-primary read-clipboard read-primary";
          allow_hyperlinks = "yes";
          confirm_os_window_close = 0;
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

