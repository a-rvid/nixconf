{
  flake.nixosModules.flatpak = {pkgs, ...}: {
    services.flatpak.enable = true;

    persistance.cache.directories = [
      ".var/app"
      ".local/share/flatpak"
    ];
  };

  services.flatpak.update.auto.enable = false;

  services.flatpak.remotes = lib.mkOptionDefault [{
    name = "flathub";
    url = "https://flathub.org/repo/flathub.flatpakrepo";
  }];

  services.flatpak.packages = [
    "com.bambulab.BambuStudio"
  ];
}