{}: {
  /*
  *
  Select the old or new value depending on if `name` exists `set`

  # Inputs
  ```
    {
      name: the name of the attributes to check the existence for.
      set: the attributes set to check the existence of `name` in.
      new: the "new" value to select if `name` exists in `set`.
      old: the "old" value to select if `name` doesn't exist in `set`.
    }
  ```

  # Type

  ```
    mkCompatibilityAttrs :: {str, attrs, a, a } -> a
  ```

  # Examples

  ```nix
  mkCompatibilityAttrs {
    name = "file-roller";
    set = pkgs;
    new = pkgs.file-roller;
    old = pkgs.gnome.file-roller;
  }
  => pkgs.file-roller

  ```
  */
  mkCompatibilityAttrs = {
    name,
    set,
    new,
    old,
  }:
    if (builtins.hasAttr name set)
    then new
    else old;
}
