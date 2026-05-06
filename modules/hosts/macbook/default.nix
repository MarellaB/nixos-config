{ self, inputs, ... }: {
  flake.darwinConfigurations.macbook = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [
      self.darwinModules.macbookConfiguration

      inputs.home-manager.darwinModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.users.brandon = {
          home.stateVersion = "25.11";
          home.username = "brandon";
          home.homeDirectory = "/Users/brandon";
        };
      }
			self.darwinModules.shell
      self.darwinModules.development
    ];
  };
}
