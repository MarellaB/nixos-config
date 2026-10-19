{ self, inputs, ... }: {
  flake.nixosModules.homeManager = { pkgs, lib, config, ... }:
    let
      isDesktop = config.networking.hostName == "brandons-nixos-desktop";

      noctaliaLock = pkgs.writeShellScriptBin "noctalia-lock" ''
        for _ in $(seq 1 25); do
          if ${lib.getExe pkgs.noctalia} msg session lock 2>/dev/null; then
            exit 0
          fi
          sleep 0.2
        done
        exit 1
      '';

      # Forces Noctalia to recompute its per-screen bar/wallpaper geometry
      # (bound to lid-switch/monitor-change hooks in work-laptop.lua).
      noctaliaRefreshMonitors = pkgs.writeShellScriptBin "noctalia-refresh-monitors" ''
        ${lib.getExe pkgs.noctalia} msg dpms-off
        sleep 0.3
        ${lib.getExe pkgs.noctalia} msg dpms-on
      '';
    in {
      imports = [ inputs.home-manager.nixosModules.home-manager ];
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";

      # Opens the ports used for LocalSend
      networking.firewall.allowedTCPPorts = [ 53317 ];
      networking.firewall.allowedUDPPorts = [ 53317 ];

      services.blueman.enable = true;

      programs.noctalia = {
        enable = true;
        systemd = {
          enable = true;
          target = "hyprland-session.target";
        };
        recommendedServices.enable = true;
      };

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
          noctaliaLock
          noctaliaRefreshMonitors
        ];

        home.pointerCursor = {
          enable = true;
          package = pkgs.adwaita-icon-theme;
          name = "Adwaita";
          size = 24;
        };

        services.hypridle = {
          enable = true;
          systemdTarget = "hyprland-session.target";
          settings.general.before_sleep_cmd = "noctalia-lock";
        };

        systemd.user.services = {
          blueman-applet = {
            Unit = {
              Description = "Blueman Bluetooth pairing agent";
              After = [ "hyprland-session.target" ];
              PartOf = [ "hyprland-session.target" ];
            };
            Service = {
              ExecStart = "${pkgs.blueman}/bin/blueman-applet";
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
      };
    };
}
