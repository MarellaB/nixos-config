{ self, inputs, ... }: {
  flake.nixosModules.homeManager = { pkgs, lib, config, ... }:
    let
      isDesktop = config.networking.hostName == "brandons-nixos-desktop";
      myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
        inherit pkgs;
        settings = builtins.fromJSON (builtins.readFile (
          if isDesktop then ./noctalia/desktop.json
          else ./noctalia/workLaptop.json
        ));
      };
      # Manual lock command (bound to a keybind in common.lua). Noctalia's
      # IPC can't find the running instance by config path (a bug on this
      # version -- `noctalia-shell ipc show` reports "No running instances"
      # even for the exact path it was launched with), so target it by PID
      # instead. `loginctl lock-session` does NOT reach Noctalia's lock
      # screen on this version either; its own lockScreen.lock() IPC call
      # is what actually works. Retries briefly in case it's ever called
      # before noctalia-shell has finished starting.
      noctaliaLock = pkgs.writeShellScriptBin "noctalia-lock" ''
        for _ in $(seq 1 50); do
          pid=$(${pkgs.procps}/bin/pgrep -f 'bin/quickshell -p .*noctalia-shell$' || true)
          if [ -n "$pid" ] && ${lib.getExe myNoctalia} ipc --pid "$pid" call lockScreen lock 2>/dev/null; then
            exit 0
          fi
          sleep 0.2
        done
        exit 1
      '';

      # Forces Noctalia to recompute its per-screen bar/wallpaper geometry
      # (bound to lid-switch/monitor-change hooks in work-laptop.lua).
      noctaliaRefreshMonitors = pkgs.writeShellScriptBin "noctalia-refresh-monitors" ''
        pid=$(${pkgs.procps}/bin/pgrep -f 'bin/quickshell -p .*noctalia-shell$') || exit 0
        ${lib.getExe myNoctalia} ipc --pid "$pid" call monitors off
        sleep 0.3
        ${lib.getExe myNoctalia} ipc --pid "$pid" call monitors on
      '';
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
      };
    };
}
