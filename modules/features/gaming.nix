{ ... }: {
  flake.nixosModules.gaming = { pkgs, ... }: {
    
		programs.steam = {
	    enable = true;
			remotePlay.openFirewall = true; #Open ports in the firewall for Steam Remote Play
			dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server (when needed)
			localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
			gamescopeSession.enable = true; # Enables gamescope for steam games
		};

    home-manager.users.brandon = {
      home.packages = with pkgs; [
        prismlauncher
      ];
    };

  };
}
