{ extra-types, ... }:

{
  options.hellebore.theme = {
    inherit (extra-types) themes;

    name = extra-types.themeName {
      description = "Defines the name of the theme applied globally.";
    };
  };
}

