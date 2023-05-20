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
  };
}
