{ colors, mkLiteral }:

let
  vertical-theme = import ./vertical.nix;
  horizontal-theme = import ./horizontal.nix;
in
{
  bluetooth = { image, font }: vertical-theme {
    inherit image font mkLiteral;

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

  favorites = { image, font }: horizontal-theme {
    inherit image font mkLiteral;

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

  mpd = { image, font }: horizontal-theme {
    inherit image font mkLiteral;

    background = colors.normal.crust;
    background-alt = colors.normal.base;
    text = colors.normal.text;
    selected = colors.normal.sky;
    selected-alt = colors.darken.sky;
    highlight = colors.normal.sapphire;
    highlight-alt = colors.darken.sapphire;
    active = colors.normal.green;
    active-alt = colors.darken.green;
    urgent = colors.normal.maroon;
    urgent-alt = colors.darken.maroon;
    icon = "󰽴";
  };

  network-manager = { image, font }: vertical-theme {
    inherit image font mkLiteral;

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

  power-profiles = { image, font }: horizontal-theme {
    inherit image font mkLiteral;

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

  quicklinks = { image, font }: horizontal-theme {
    inherit image font mkLiteral;

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

