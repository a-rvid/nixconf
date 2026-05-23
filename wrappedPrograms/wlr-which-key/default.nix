{
  inputs,
  self,
  lib,
  ...
}: let
  theme = {
    base00 = "#242424"; # bg
    base01 = "#3c3836"; # dark
    base02 = "#504945";
    base03 = "#665c54";
    base04 = "#bdae93";
    base05 = "#d5c4a1";
    base06 = "#ebdbb2"; # fg
    base07 = "#fbf1c7"; # light fg
    base08 = "#fb4934"; # red
    base09 = "#fe8019"; # orange
    base0A = "#fabd2f"; # yellow
    base0B = "#b8bb26"; # green
    base0C = "#8ec07c"; # cyan
    base0D = "#7daea3"; # blue
    base0E = "#e089a1"; # magenta
    base0F = "#f28534"; # orange
  };

  mkWhichKey = pkgs: menu:
    (self.wrappersModules.which-key.apply {
      inherit pkgs;
      settings = {
        inherit menu;

        font = "JetBrainsMono Nerd Font 12";
        background = theme.base00;
        color = theme.base06;
        border = theme.base0F;
        separator = " ➜ ";
        border_width = 2;
        corner_r = 15;
        padding = 15;
        rows_per_column = 5;
        column_padding = 25;

        anchor = "bottom-right";
        margin_right = 0;
        margin_bottom = 5;
        margin_left = 5;
        margin_top = 0;
      };
    }).wrapper;
in {
  flake.mkWhichKeyExe = pkgs: menu: lib.getExe (mkWhichKey pkgs menu);

  flake.wrappersModules.which-key = inputs.wrappers.lib.wrapModule (
    {
      config,
      lib,
      ...
    }: let
      yamlFormat = config.pkgs.formats.yaml {};
    in {
      options = {
        settings = lib.mkOption {
          type = yamlFormat.type;
        };
      };

      config = {
        package = config.pkgs.wlr-which-key;

        args = [
          (toString (yamlFormat.generate "config.yaml" config.settings))
        ];
      };
    }
  );
}
