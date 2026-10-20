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

      # Cycles the default audio output
      audioCycle = pkgs.writeShellApplication {
        name = "audio-cycle";
        runtimeInputs = with pkgs; [ wireplumber pipewire jq util-linux coreutils gawk ];
        text = ''
          wanted=(${lib.escapeShellArgs config.custom.audioCycle.sinks})
          if [ "$#" -gt 0 ]; then
            wanted=("$@")
          fi

          log() {
            logger -t audio-cycle -- "$*"
            echo "audio-cycle: $*" >&2
          }

          # "<id> <node.name>" for every sink currently present, sorted by name
          mapfile -t sinks < <(
            pw-dump | jq -r '.[]
              | select(.type == "PipeWire:Interface:Node"
                       and .info.props["media.class"] == "Audio/Sink")
              | "\(.id) \(.info.props["node.name"])"' | sort -k2
          )

          ids=()
          names=()
          if [ "''${#wanted[@]}" -eq 0 ]; then
            for entry in "''${sinks[@]}"; do
              ids+=("''${entry%% *}")
              names+=("''${entry#* }")
            done
          else
            for pattern in "''${wanted[@]}"; do
              found=0
              for entry in "''${sinks[@]}"; do
                if [[ "''${entry#* }" == *"$pattern"* ]]; then
                  ids+=("''${entry%% *}")
                  names+=("''${entry#* }")
                  found=1
                  break
                fi
              done
              if [ "$found" -eq 0 ]; then
                log "skipping '$pattern': no matching sink is present"
              fi
            done
          fi

          if [ "''${#ids[@]}" -eq 0 ]; then
            log "no usable sinks found (wanted: ''${wanted[*]:-all})"
            exit 1
          fi

          current=$(wpctl inspect @DEFAULT_AUDIO_SINK@ | awk -F'"' '/node.name/ { print $2; exit }')

          # Start before the first entry so an unlisted current sink lands on index 0
          index=-1
          for i in "''${!names[@]}"; do
            if [ "''${names[$i]}" = "$current" ]; then
              index=$i
              break
            fi
          done

          next=$(( (index + 1) % ''${#ids[@]} ))
          wpctl set-default "''${ids[$next]}"
          log "default output: ''${current:-unknown} -> ''${names[$next]}"
        '';
      };
    in {
      imports = [
        inputs.home-manager.nixosModules.home-manager
        self.nixosModules.audioCycleOptions
      ];

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
          audioCycle
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

  # Per-host list for audio-cycle; hosts set custom.audioCycle.sinks.
  flake.nixosModules.audioCycleOptions = { lib, ... }: {
    options.custom.audioCycle.sinks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "alsa_output.pci-0000_2b_00.4.analog-stereo" ];
      description = ''
        Ordered substrings of PipeWire sink node names that audio-cycle
        rotates through. Empty (the default) rotates through every sink.
      '';
    };
  };
}
