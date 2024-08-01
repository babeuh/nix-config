{ lib, hostname, ... }:
{
  imports = [
    ../common
    ../common/gaming
    ../common/distrobox
  ];

  variables.git = {
    name = "Babeuh";
    email = "babeuh@rlglr.fr";
  };

  variables.isLaptop = false;
}
