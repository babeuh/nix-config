{ lib, ... }:
with lib;
{
  options.variables = {
    git = {
      name = mkOption {
        type = types.str;
        description = "User's git name";
      };
      email = mkOption {
        type = types.str;
        description = "The main user's home directory";
      };
    };
    isLaptop = mkOption {
      type = types.bool;
      description = "Is the configuration running on a laptop";
    };
  };
}
