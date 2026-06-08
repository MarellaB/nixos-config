{ self, inputs, ... }: {
  flake.nixosModules.homeManager = { pkgs, lib, config, ... }:
    let
      myNoctalia = self.packages.${pkgs.stdenv.hostPlatform.system}.myNoctalia;
      isDesktop = config.networking.hostName == "brandons-nixos-desktop";
      isWorkLaptop = config.networking.hostName == "brandon-marellas-work-laptop";
    in {
      imports = [ inputs.home-manager.nixosModules.home-manager ];
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";

      home-manager.users.brandon = {
        home.stateVersion = "25.11";
        home.username = "brandon";
        home.homeDirectory = "/home/brandon";
        home.sessionPath = [
          "$HOME/.config/emacs/bin"
          "$HOME/.cargo/bin"
        ];

        home.packages = with pkgs; [
          playerctl
          hyprshot
          spotify
          logseq
          localsend
        ];

        home.pointerCursor = {
          gtk.enable = true;
          package = pkgs.adwaita-icon-theme;
          name = "Adwaita";
          size = 24;
        };


        wayland.windowManager.hyprland = {
          enable = true;
          settings = {
            monitor = if isDesktop then [
              "DP-1,5120x1440@119.970,0x0,1"
              "DP-2,1920x1080@60,5120x-480,1,transform,1"
              "DP-3,1920x1080@60,-1080x-480,1,transform,3"
              "HDMI-A-1,3840x2160@60,1280x-1440,1.5"
            ] else [
              "eDP-1,1920x1200@60,0x0,1"
            ];
            exec-once = [
              (lib.getExe pkgs.hyprlock)
              (lib.getExe myNoctalia)
            ];
            input = {
              kb_layout = "us,ua";
              follow_mouse = 1;
              repeat_rate = 70;
              repeat_delay = 250;
            };
            general = {
              gaps_in = 6;
              gaps_out = 12;
              "col.active_border" = "rgba(DDDDDDAA)";
              "col.inactive_border" = "rgba(DDDDDD33)";
            };
            decoration = {
              rounding = 6;
              active_opacity = 1.0;
              inactive_opacity = 0.9;
            };
            workspace = if isDesktop then [
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
            ] else if isWorkLaptop then [
              "1, monitor:DP-3"
              "2, monitor:DP-3"
              "3, monitor:DP-3"
              "4, monitor:DP-3"
              "5, monitor:DP-3"
              "6, monitor:DP-3"
              "7, monitor:DP-3"
              "8, monitor:DP-3"
              "9, monitor:DP-3"

              "10, monitor:DP-4"
            ] else [ ];
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
              "$mod, B, exec, ${lib.getExe pkgs.firefox}"
              "$mod, E, exec, ${lib.getExe pkgs.emacs}"

              "$mod, Q, killactive"
              "$mod SHIFT, Q, forcekillactive"
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
              ", switch:Lid Switch, exec, hyprctl keyword monitor 'eDP-1, preferred, auto, 1'"
              ", switch:on:Lid Switch, exec, hyprctl monitors | grep -q -v 'eDP-1' && hyprctl keyword monitor 'eDP-1, disable' || systemctl suspend"
            ];
            bindm = [
              "$mod, mouse:272, movewindow"
              "$mod, mouse:273, resizewindow"
            ];
            env = [
              "XCURSOR_THEME,Adwaita"
              "XCURSOR_SIZE,24"
            ];
            device = [
              {
                name = "logitech-mx-master-4";
                # Invert horizontal scrolling
                scroll_points = "1 0 0 -1";
              }
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
            input-field = [
              {
                monitor = "DP-1";
                size = "400, 60";
                outline_thickness = 1;
                outer_color = "rgb(255, 255, 255)";
                inner_color = "rgb(0, 0, 0)";
                font_color = "rgb(255, 255, 255)";
                placeholder_text = "Password";
                halign = "center";
                valign = "center";
              }
              {
                monitor = "eDP-1";
                size = "400, 60";
                outline_thickness = 1;
                outer_color = "rgb(255, 255, 255)";
                inner_color = "rgb(0, 0, 0)";
                font_color = "rgb(255, 255, 255)";
                placeholder_text = "Password";
                halign = "center";
                valign = "center";
              }
              {
                monitor = "DP-3";
                size = "400, 60";
                outline_thickness = 1;
                outer_color = "rgb(255, 255, 255)";
                inner_color = "rgb(0, 0, 0)";
                font_color = "rgb(255, 255, 255)";
                placeholder_text = "Password";
                halign = "center";
                valign = "center";
              }
            ];
          };
        };
      };
    };
}
