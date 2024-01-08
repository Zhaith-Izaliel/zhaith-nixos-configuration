{ colors, mkLiteral }:

let
  vertical-theme = import ./vertical.nix;
  horizontal-theme = import ./horizontal.nix;
in
{
  bluetooth = { font }: vertical-theme {
    inherit font mkLiteral;

    image = ../../../../../assets/images/rofi/rofi-bluetooth-wall.jpg;
    background = colors.normal.base;
    background-alt = colors.normal.crust;
    text = colors.normal.text;
    selected = colors.normal.sapphire;
    highlight = colors.normal.sky;
    highlight-alt = colors.darken.sky;
    active = colors.normal.teal;
    urgent = colors.normal.maroon;
    icon = "";
  };

  favorites = { font }: horizontal-theme {
    inherit font mkLiteral;

    image = ../../../../../assets/images/rofi/rofi-favorites-wall.jpg;
    background = colors.normal.crust;
    background-alt = colors.normal.base;
    text = colors.normal.text;
    selected = colors.normal.rosewater;
    selected-alt = colors.darken.rosewater;
    highlight = colors.normal.yellow;
    highlight-alt = colors.darken.yellow;
    active = colors.normal.peach;
    active-alt = colors.darken.peach;
    urgent = colors.normal.maroon;
    urgent-alt = colors.darken.maroon;
    icon = "";
  };

  mpd = { font }: horizontal-theme {
    inherit font mkLiteral;

    image = ../../../../../assets/images/rofi/rofi-mpd-wall.jpg;
    background = colors.normal.crust;
    background-alt = colors.normal.base;
    text = colors.normal.text;
    selected = colors.normal.mauve;
    selected-alt = colors.darken.mauve;
    highlight = colors.normal.lavender;
    highlight-alt = colors.darken.lavender;
    active = colors.normal.pink;
    active-alt = colors.darken.pink;
    urgent = colors.normal.red;
    urgent-alt = colors.darken.red;
    icon = "󰽴";
  };

  network-manager = { font }: vertical-theme {
    inherit font mkLiteral;

    image = ../../../../../assets/images/rofi/wall.png;
    background = colors.normal.base;
    background-alt = colors.normal.crust;
    text = colors.normal.text;
    selected = colors.normal.lavender;
    highlight = colors.normal.mauve;
    highlight-alt = colors.darken.mauve;
    active = colors.normal.sky;
    urgent = colors.normal.maroon;
    icon = "";
  };

  power-profiles = { font }: horizontal-theme {
    inherit font mkLiteral;

    image = ../../../../../assets/images/rofi/rofi-power-profiles-wall.jpg;
    background = colors.normal.crust;
    background-alt = colors.normal.base;
    text = colors.normal.text;
    selected = colors.normal.maroon;
    selected-alt = colors.darken.maroon;
    highlight = colors.normal.red;
    highlight-alt = colors.darken.red;
    active = colors.normal.green;
    active-alt = colors.darken.green;
    urgent = colors.normal.peach;
    urgent-alt = colors.darken.peach;
    icon = "󱐋";
  };

  quicklinks = { font }: horizontal-theme {
    inherit font mkLiteral;

    image = ../../../../../assets/images/rofi/wall.png;
    background = colors.normal.crust;
    background-alt = colors.normal.base;
    text = colors.normal.text;
    selected = colors.normal.mauve;
    selected-alt = colors.darken.mauve;
    highlight = colors.normal.blue;
    highlight-alt = colors.darken.blue;
    active = colors.normal.lavender;
    active-alt = colors.darken.lavender;
    urgent = colors.normal.maroon;
    urgent-alt = colors.darken.maroon;
    icon = "";
  };
}

