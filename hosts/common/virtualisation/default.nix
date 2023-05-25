{ pkgs, config, ... }: {
  environment.systemPackages = with pkgs; [
    virt-manager
  ];
  virtualisation = {
    libvirtd.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };
  users.users.${config.variables.user.name}.extraGroups = [ "libvirtd" ];
}
