{
  disk ? null,
  ...
}:
{
  disko.devices = {
    disk = {
      vdb = {
        type = "disk";
        device =
          assert disk != null;
          disk;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "defaults" ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "root";
                settings.keyFile = "/tmp/secret.key";
                content = {
                  type = "lvm_pv";
                  vg = "lvm";
                };
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      lvm = {
        type = "lvm_vg";
        lvs = {
          NIXOS-SWAP = {
            size = "16G";
            content = {
              type = "swap";
            };
          };
          NIXOS-ROOT = {
            size = "100%";
            content = {
              type = "btrfs";
              mountOptions = [ "compress=zstd noatime" ];
              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                };
                "/home" = {
                  mountpoint = "/home";
                };
                "/nix" = {
                  mountpoint = "/nix";
                };
                "/persist" = {
                  mountpoint = "/persist";
                };
                "/log" = {
                  mountpoint = "/var/log";
                };
              };
            };
          };
        };
      };
    };
  };
}
