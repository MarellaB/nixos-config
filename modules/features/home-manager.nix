{ self, inputs, ... }: {
  flake.nixosModules.homeManager = { pkgs, lib, ... }:
  let
    myNoctalia = self.packages.${pkgs.stdenv.hostPlatform.system}.myNoctalia;
  in {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "backup";

    home-manager.users.brandon = {
      home.stateVersion = "25.11";
      home.username = "brandon";
      home.homeDirectory = "/home/brandon";

      home.packages = with pkgs; [
        playerctl
        hyprshot
        ripgrep
        fd

        spotify
				nerd-fonts.jetbrains-mono
      ];

      home.pointerCursor = {
        gtk.enable = true;
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        size = 24;
      };

      programs.kitty = {
        enable = true;
        themeFile = "Nord";
				font = {
					name = "JetBrainsMono Nerd Font";
					size = 11;
				};
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

      programs.zsh = {
        enable = true;
        initExtra = ''
          rebuild() {
            local host=''${1:-desktop}
            local extra_args=''${@:2}

            if [[ "$(uname)" == "Darwin" ]]; then
              darwin-rebuild switch --flake ~/nixos-config#macbook $extra_args
            else
              sudo nixos-rebuild switch --flake ~/nixos-config#$host $extra_args
            fi
          }
        '';
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
        matchBlocks = {
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

      wayland.windowManager.hyprland = {
        enable = true;
        settings = {
          monitor = [
            "DP-1,5120x1440@119.970,0x0,1"
            "DP-2,1920x1080@60,5120x-480,1,transform,1"
            "DP-3,1920x1080@60,-1080x-480,1,transform,3"
            "HDMI-A-1,3840x2160@60,1280x-1440,1.5"
          ];
          exec-once = [
            (lib.getExe pkgs.hyprlock)
            (lib.getExe myNoctalia)
          ];
          input = {
            kb_layout = "us,ua";
            follow_mouse = 1;
          };
          general = {
            gaps_in = 6;
            gaps_out = 12;
          };
          decoration = {
            rounding = 8;
            active_opacity = 1.0;
            inactive_opacity = 0.9;
          };
          workspace = [
            "1, monitor:DP-1"
            "2, monitor:DP-1"
            "3, monitor:DP-1"
            "4, monitor:DP-1"
            "5, monitor:DP-1"
            "6, monitor:DP-1"
            "7, monitor:DP-1"

            "8, monitor:DP-3"
            "9, monitor:HDMI-A-1"
            "10, monitor:DP-2"
          ];
          animations = {
            enabled = true;
            animation = [
              "windows,1,2,default"
              "border,1,2,default"
              "fade,1,2,default"
              "workspaces,1,2,default"
            ];
          };
          "$mod" = "SUPER";
          bind = [
            "$mod, C, exec, ${lib.getExe pkgs.kitty}"
            "$mod, Q, killactive"
            "$mod SHIFT, Q, forcekillactive"
            "$mod, B, exec, ${lib.getExe pkgs.firefox}"
            "$mod SHIFT, F, fullscreen, 0"
            "$mod, P, pseudo"
            "$mod, V, togglefloating"
            "$mod CTRL SHIFT, 4, exec, ${lib.getExe pkgs.hyprshot} -m region --clipboard-only"
            "$mod CTRL SHIFT, L, exec, ${lib.getExe pkgs.hyprlock}"
            "$mod, Space, exec, ${lib.getExe myNoctalia} ipc call launcher toggle"

            # Auto-Center a window
            "$mod SHIFT, P, exec, hyprctl dispatch resizeactive exact 2560 1440 && hyprctl dispatch centerwindow"

            "$mod, H, movefocus, l"
            "$mod SHIFT, H, movewindow, l"
            "$mod, L, movefocus, r"
            "$mod SHIFT, L, movewindow, r"
            "$mod, K, movefocus, u"
            "$mod SHIFT, K, movewindow, u"
            "$mod, J, movefocus, d"
            "$mod SHIFT, J, movewindow, d"

            "$mod, 1, workspace, 1"
            "$mod, 2, workspace, 2"
            "$mod, 3, workspace, 3"
            "$mod, 4, workspace, 4"
            "$mod, 5, workspace, 5"
            "$mod, 6, workspace, 6"
            "$mod, 7, workspace, 7"
            "$mod, 8, workspace, 8"
            "$mod, 9, workspace, 9"
            "$mod, 0, workspace, 10"
            "$mod SHIFT, 1, movetoworkspace, 1"
            "$mod SHIFT, 2, movetoworkspace, 2"
            "$mod SHIFT, 3, movetoworkspace, 3"
            "$mod SHIFT, 4, movetoworkspace, 4"
            "$mod SHIFT, 5, movetoworkspace, 5"
            "$mod SHIFT, 6, movetoworkspace, 6"
            "$mod SHIFT, 7, movetoworkspace, 7"
            "$mod SHIFT, 8, movetoworkspace, 8"
            "$mod SHIFT, 9, movetoworkspace, 9"
            "$mod SHIFT, 0, movetoworkspace, 10"

            "$mod, S, togglespecialworkspace"
            "$mod SHIFT, S, movetoworkspace, special"
          ];
          bindl = [
            ", XF86AudioPlay, exec, playerctl play-pause"
            ", XF86AudioPause, exec, playerctl play-pause"
            ", XF86AudioNext, exec, playerctl next"
            ", XF86AudioPrev, exec, playerctl previous"
            ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
            ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
            ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ];
          bindm = [
            "$mod, mouse:272, movewindow"
            "$mod, mouse:273, resizewindow"
          ];
          env = [
            "XCURSOR_THEME,Adwaita"
            "XCURSOR_SIZE,24"
          ];
        };
      };


      programs.hyprlock = {
        enable = true;
        settings = {
          background = [{
            monitor = "";
            color = "rgba(0, 0, 0, 1.0)";
          }];
          input-field = [{
            monitor = "DP-1";
            size = "400, 60";
            outline_thickness = 1;
            outer_color = "rgb(255, 255, 255)";
            inner_color = "rgb(0, 0, 0)";
            font_color = "rgb(255, 255, 255)";
            placeholder_text = "Password";
            halign = "center";
            valign = "center";
          }];
        };
      };
    };
  };
}
