{
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
    email = "60193302+babeuh@users.noreply.github.com";
  };
}
