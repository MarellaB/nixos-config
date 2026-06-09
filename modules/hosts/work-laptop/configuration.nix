{ self, ... }: {

  flake.nixosModules.workLaptopConfiguration = { config, pkgs, ... }: {
    imports = [
      self.nixosModules.workLaptopHardware
      self.nixosModules.shell
      self.nixosModules.hyprland
      self.nixosModules.homeManager
      self.nixosModules.development
      self.nixosModules.virtualisation
      self.nixosModules.work
      self.nixosModules.syncthing
    ];

    _module.args = {
      syncthingName = "workLaptop";
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    hardware.graphics.extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    powerManagement.enable = true;
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;

    # Used for inventory management for Dolbey
    services.glpiAgent = {
      enable = true;

      settings = {
        server = "https://glpi.dolbey.com/front/inventory.php";
        tag = "nixos";
      };
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

    networking.hostName = "brandon-marellas-work-laptop";
    networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Enable networking
    networking.networkmanager.enable = true;

    services.tailscale.enable = true;

    services.flatpak.enable = true;
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

    # Enable the X11 windowing system
    # And configure keymap in X11
    services.xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
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
    services.libinput.enable = true;

    users.users.brandon = {
      isNormalUser = true;
      description = "brandon";
      extraGroups = [ "networkmanager" "wheel" ];
      shell = pkgs.zsh;
    };

    # Install firefox.
    programs.firefox.enable = true;
    programs.zsh.enable = true;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      git
      kitty
      xwayland-satellite # X11 Compatability for Wayland
      glpi-agent
      libreoffice
      xdg-utils
    ];

    # DO NOT, change this value, unless you SPECIFICALLY know why.
    system.stateVersion = "25.11"; # Did you read the comment?
  };
}
