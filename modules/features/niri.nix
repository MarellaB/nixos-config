{ self, inputs, ... }: {

	flake.nixosModules.niri = { pkgs, lib, ... }: {
	  programs.niri = {
	    enable = true;
	    package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
	  };
	};

  perSystem = { pkgs, lib, self', ... }: {

    packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = {

      	spawn-at-startup = [
		(lib.getExe self'.packages.myNoctalia) # Noctalia
		(lib.getExe pkgs.hyprlock)
	];

	input = {
		keyboard = {
          		xkb.layout = "us,ua";
		};
		focus-follows-mouse = _: { props = { max-scroll-amount = "50%"; }; };
	};

	layout.gaps = 12;

	outputs = {
		# Super Ultrawide
		"DP-1" = {
			mode = "5120x1440@119.970";
			position = _: {
				props = { x=0; y=0; };
			};
			focus-at-startup = _: {};
			hot-corners.off = _: {};
		};

		# Right Vertical Monitor
		"DP-2" = {
			transform = "90";
			position = _: {
				props = { x=5120; y=-400; };
			};
			hot-corners.off = _: {};
		};

		# Left Vertical Monitor
		"DP-3" = {
			transform = "270";
			position = _: {
				props = { x=-1080; y=-400; };
			};
			hot-corners.off = _: {};
		};

		# Top Monitor
		"HDMI-A-1" = {
			scale = 1.5;
			position = _: {
				props = { x=1280; y=-1440; };
			};
			hot-corners.off = _: {};
		};
	};

	binds = {
          "Mod+C".spawn = lib.getExe pkgs.kitty;
	  "Mod+Q".close-window = _: {};
	  "Mod+B".spawn = lib.getExe pkgs.firefox;
	  "Mod+Space".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";
	  "Mod+Ctrl+Shift+L".spawn = lib.getExe pkgs.hyprlock;

	  # Movement Keybinds
	  "Mod+H".focus-column-left = _: {};
	  "Mod+Shift+H".move-column-left = _: {};
  	  "Mod+L".focus-column-right = _: {};
  	  "Mod+Shift+L".move-column-right = _: {};

	  # Navigate windows within a column
	  "Mod+Up".focus-window-up = _: {};
	  "Mod+Down".focus-window-down = _: {};

	  # Move windows within a column
	  "Mod+Shift+Up".move-window-up = _: {};
	  "Mod+Shift+Down".move-window-down = _: {};

	  # Fullscreen toggle
	  "Mod+F".fullscreen-window = _: {};

	  # Workspaces 1-7 on main monitor
	  "Mod+1".focus-workspace = 1;
	  "Mod+2".focus-workspace = 2;
	  "Mod+3".focus-workspace = 3;
	  "Mod+4".focus-workspace = 4;
	  "Mod+5".focus-workspace = 5;
	  "Mod+6".focus-workspace = 6;
	  "Mod+7".focus-workspace = 7;

	  # 8/9/10 = focus left/top/right monitor
	  "Mod+8".focus-monitor-left = _: {};
	  "Mod+9".focus-monitor-up = _: {};
	  "Mod+0".focus-monitor-right = _: {};

	  # Send window to workspaces 1-7
	  "Mod+Shift+1".move-column-to-workspace = 1;
	  "Mod+Shift+2".move-column-to-workspace = 2;
	  "Mod+Shift+3".move-column-to-workspace = 3;
	  "Mod+Shift+4".move-column-to-workspace = 4;
	  "Mod+Shift+5".move-column-to-workspace = 5;
	  "Mod+Shift+6".move-column-to-workspace = 6;
	  "Mod+Shift+7".move-column-to-workspace = 7;

	  # Send window to left/top/right monitor
	  "Mod+Shift+8".move-column-to-monitor-left = _: {};
	  "Mod+Shift+9".move-column-to-monitor-up = _: {};
	  "Mod+Shift+0".move-column-to-monitor-right = _: {};
	};
      };

    };

  };

}
