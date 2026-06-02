{ ... }: {

  flake.nixosModules.workLaptopHardware = { config, lib, pkgs, modulesPath, ... }:
	{
		imports =
			[ (modulesPath + "/installer/scan/not-detected.nix")
			];

		boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "rtsx_pci_sdmmc" ];
		boot.initrd.kernelModules = [ ];
		boot.kernelModules = [ "kvm-intel" ];
		boot.extraModulePackages = [ ];

		fileSystems."/" =
			{ device = "/dev/disk/by-uuid/f3da0692-563b-452f-81f4-7890648258ee";
				fsType = "btrfs";
			};

		fileSystems."/nix" =
			{ device = "/dev/disk/by-uuid/f3da0692-563b-452f-81f4-7890648258ee";
				fsType = "btrfs";
				options = [ "subvol=nix" ];
			};

		fileSystems."/home" =
			{ device = "/dev/disk/by-uuid/f3da0692-563b-452f-81f4-7890648258ee";
				fsType = "btrfs";
				options = [ "subvol=home" ];
			};

		fileSystems."/boot" =
			{ device = "/dev/disk/by-uuid/485C-ECF5";
				fsType = "vfat";
				options = [ "fmask=0077" "dmask=0077" ];
			};

		swapDevices =
			[ { device = "/dev/disk/by-uuid/281cd0fc-ee53-4e49-a566-f4b341bb8ccb"; }
			];

		nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
		hardware.cpu.intel.npu.enable = true;
		hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
	};
}
