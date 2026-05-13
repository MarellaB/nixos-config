{ self, inputs, ... }: {

  flake.nixosConfigurations.workLaptop = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.workLaptopConfiguration
    ];
  };

}
