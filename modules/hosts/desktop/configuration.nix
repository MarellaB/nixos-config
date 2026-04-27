{ self, inputs, ... }: {

  flake.nixosModules.desktopConfiguration = { config, pkgs, ... }: {
	  imports = [ 
	    self.nixosModules.desktopHardware
	    # self.nixosModules.niri # Commented out as just not sure how to work with this yet...
	    self.nixosModules.hyprland
	    self.nixosModules.homeManager
	  ];

	  # Enables NVIDIA drivers and Configurations (Should be moved to Desktop Host when flaked)
	  hardware.graphics.enable = true;
	  services.xserver.videoDrivers = ["nvidia"];
	  hardware.nvidia = {
	    modesetting.enable = true;
	    open = true;
	    nvidiaSettings = true;
	  };

	  # Setup Nix Garbage Collection for weekly runs (deletes older than 7 days)
	  nix.gc = {
	    automatic = true;
	    dates = "daily";
	    options = "--delete-older-than 7d";
	  };

	  nix.settings.experimental-features = [ "nix-command" "flakes" ];

	  # Bootloader.
	  boot.loader.systemd-boot.enable = true;
	  boot.loader.efi.canTouchEfiVariables = true;

	  networking.hostName = "brandons-nixos-desktop";
	  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

	  # Enable networking
	  networking.networkmanager.enable = true;

    services.greetd = {
	  enable = true;
	  settings = {
	    default_session = {
	      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
	      user = "greeter";
	    };
	    initial_session = {
		command = "start-hyprland";
		user = "brandon";
	    };
	  };
	};


	  time.timeZone = "America/New_York";
	  i18n.defaultLocale = "en_US.UTF-8";
	  i18n.extraLocaleSettings = {
	    LC_ADDRESS = "en_US.UTF-8";
	    LC_IDENTIFICATION = "en_US.UTF-8";
	    LC_MEASUREMENT = "en_US.UTF-8";
	    LC_MONETARY = "en_US.UTF-8";
	    LC_NAME = "en_US.UTF-8";
	    LC_NUMERIC = "en_US.UTF-8";
	    LC_PAPER = "en_US.UTF-8";
	    LC_TELEPHONE = "en_US.UTF-8";
	    LC_TIME = "en_US.UTF-8";
	  };

	  # Enable the X11 windowing system.
	  services.xserver.enable = true;

	  # Enable the GNOME Desktop Environment.
	  # services.xserver.displayManager.gdm.enable = true;
	  # services.xserver.desktopManager.gnome.enable = true;

	  # Configure keymap in X11
	  services.xserver.xkb = {
	    layout = "us";
	    variant = "";
	  };

	  # Enable CUPS to print documents.
	  services.printing.enable = true;

	  # Enable sound with pipewire.
	  services.pulseaudio.enable = false;
	  security.rtkit.enable = true;
	  services.pipewire = {
	    enable = true;
	    alsa.enable = true;
	    alsa.support32Bit = true;
	    pulse.enable = true;
	  };

	  # Enable touchpad support (enabled default in most desktopManager).
	  # services.xserver.libinput.enable = true;

	  users.users.brandon = {
	    isNormalUser = true;
	    description = "brandon";
	    extraGroups = [ "networkmanager" "wheel" ];
	    packages = with pkgs; [
	    #  thunderbird
	    ];
	  };

	  # Install firefox.
	  programs.firefox.enable = true;

	  # Allow unfree packages
	  nixpkgs.config.allowUnfree = true;

	  # List packages installed in system profile. To search, run:
	  # $ nix search wget
	  environment.systemPackages = with pkgs; [
			git
			discord
			kitty
			xwayland-satellite # X11 Compatability for Wayland
      claude-code
	  ];

		programs.steam = {
	    enable = true;
			remotePlay.openFirewall = true; #Open ports in the firewall for Steam Remote Play
			dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server (when needed)
			localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
			gamescopeSession.enable = true; # Enables gamescope for steam games
		};

    fileSystems."/mnt/ssd" = {
      device = "/dev/disk/by-uuid/e93fc391-fb97-4248-b2e8-d64fdfc96f5d";
      fsType = "ext4";
    };

	  # DO NOT, change this value, unless you SPECIFICALLY know why.
	  system.stateVersion = "25.11"; # Did you read the comment?
	};
}
