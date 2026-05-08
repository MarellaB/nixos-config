# This will ONLY work on Linux systems
# Not MacOS or Windows
{ ... }: {
  flake.nixosModules.virtualisation = {
		users.users.brandon.extraGroups = [ "docker" ];
		virtualisation.docker.enable = true;
  };
}
