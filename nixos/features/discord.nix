{
  flake.nixosModules.discord = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.vesktop
    ];

    persistance.cache.directories = [
      ".config/vesktop"
    ];
  };
}
