{ lib, pkgs, ... }:
{
  variables.git = {
    name = "Raphael Le Goaller";
    email = "babeuh@rlglr.fr";
  };
  home.packages = with pkgs; [ stdman ];
}
