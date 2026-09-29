{ self, inputs, ... }: {
  flake.nixosModules.homeManager = { pkgs, lib, config, ... }:
    let
      isDesktop = config.networking.hostName == "brandons-nixos-desktop";
      isWorkLaptop = config.networking.hostName == "brandon-marellas-work-laptop";
      myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
        inherit pkgs;
        settings = builtins.fromJSON (builtins.readFile (
          if isDesktop then ./noctalia/desktop.json
          else ./noctalia/workLaptop.json
        ));
      };
    in {
      imports = [ inputs.home-manager.nixosModules.home-manager ];
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";

      # Opens the ports used for LocalSend
      networking.firewall.allowedTCPPorts = [ 53317 ];
      networking.firewall.allowedUDPPorts = [ 53317 ];

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
          localsend
          anki
          wl-clipboard
          jq
          myNoctalia
        ];

        home.pointerCursor = {
          enable = true;
          package = pkgs.adwaita-icon-theme;
          name = "Adwaita";
          size = 24;
        };


        systemd.user.services = {
          noctalia-shell = {
            Unit = {
              Description = "Noctalia desktop shell";
              After = [ "hyprland-session.target" ];
              PartOf = [ "hyprland-session.target" ];
            };
            Service = {
              ExecStart = lib.getExe myNoctalia;
              Restart = "on-failure";
              RestartSec = 1;
            };
            Install = {
              WantedBy = [ "hyprland-session.target" ];
            };
          };
        };

        wayland.windowManager.hyprland = {
          enable = true;
          # The actual config is hand-authored Lua in ../hypr/*.lua -- real,
          # standalone files, not Nix-attrset-generated. Nix's only job here
          # is picking which per-host file to load; content is untouched.
          configType = "lua";
          extraLuaFiles = {
            common = { content = ./hypr/common.lua; autoLoad = true; };
            host = {
              content = if isDesktop then ./hypr/desktop.lua else ./hypr/work-laptop.lua;
              autoLoad = true;
            };
          };
        };


        programs.hyprlock = {
          enable = true;
          settings = {
            background = [{
              monitor = "";
              color = "rgba(0, 0, 0, 1.0)";
            }];
            input-field = if isDesktop then [
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
            ] else if isWorkLaptop then [
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
            ] else [ ];
          };
        };
      };
    };
}
