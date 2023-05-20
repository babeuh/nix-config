{ pkgs, ... }: {
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
}
