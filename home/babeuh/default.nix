{ lib, hostname, ...}: {
  imports = [
    ../common
    ../common/gaming
    ../common/distrobox
  ];

  home = {
    username = "babeuh";
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "23.05";
  };

  variables.git = {
    name = "Babeuh";
    email = "babeuh@rlglr.fr";
  };

  variables.isLaptop = if (hostname == "atlas") then false else true;

}
