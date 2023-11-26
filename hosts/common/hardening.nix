{ pkgs, lib, ... }: {
  services.chrony = {
    enable = true;
    servers = [ "time.cloudflare.com" "ntppool1.time.nl" "nts.netnod.se" "ptbtime1.ptb.de" ];
    enableNTS = true;

    extraConfig = ''
      minsources 2
      authselectmode require

      leapsectz right/UTC
      makestep 0.1 3

      cmdport 0
    '';
  };

  # Reduce fingerprinting
  environment.etc.machine-id.text = "b08dfa6083e7567a1921a715000001fb";
  networking.networkmanager = {
    ethernet.macAddress = "stable"; # Per-Network MAC
    wifi.macAddress = "stable"; # Per-Network MAC
  };

  nix.settings.allowed-users = [ "@wheel" ];
  security.sudo.execWheelOnly = true;

  boot.kernelModules = [ "usb_storage" ];

  security.virtualisation.flushL1DataCache = "always";

  security.apparmor.enable = true;
  security.apparmor.killUnconfinedConfinables = true;

  boot.blacklistedKernelModules = [
    # Obscure network protocols
    "ax25"
    "netrom"
    "rose"

    # Old or rare or insufficiently audited filesystems
    "adfs"
    "affs"
    "bfs"
    "befs"
    "cramfs"
    "efs"
    "erofs"
    "exofs"
    "freevxfs"
    "f2fs"
    "hfs"
    "hpfs"
    "jfs"
    "minix"
    "nilfs2"
    "ntfs"
    "omfs"
    "qnx4"
    "qnx6"
    "sysv"
    "ufs"
  ];

  # Restrict ptrace() usage to processes with a pre-defined relationship
  # (e.g., parent/child)
  boot.kernel.sysctl."kernel.yama.ptrace_scope" = 1;

  # Hide kptrs even for processes with CAP_SYSLOG
  boot.kernel.sysctl."kernel.kptr_restrict" = 2;

  # Disable bpf() JIT (to eliminate spray attacks)
  boot.kernel.sysctl."net.core.bpf_jit_enable" = false;

  # Disable ftrace debugging
  boot.kernel.sysctl."kernel.ftrace_enabled" = false;

  # Protect against time-wait assassination
  boot.kernel.sysctl."net.ipv4.tcp_rfc1337" = true;

  # Enable source validation of packets received (Protect against IP spoofing)
  boot.kernel.sysctl."net.ipv4.all.rp_filter" = true;
  boot.kernel.sysctl."net.ipv4.default.rp_filter" = true;

  # Enable strict reverse path filtering (that is, do not attempt to route
  # packets that "obviously" do not belong to the iface's network; dropped
  # packets are logged as martians).
  boot.kernel.sysctl."net.ipv4.conf.all.log_martians" = true;
  boot.kernel.sysctl."net.ipv4.conf.all.rp_filter" = "1";
  boot.kernel.sysctl."net.ipv4.conf.default.log_martians" = true;
  boot.kernel.sysctl."net.ipv4.conf.default.rp_filter" = "1";

  # Ignore all ICMP request (avoid SMURF attacks)
  boot.kernel.sysctl."net.ipv4.icmp_echo_ignore_all" = true;
  boot.kernel.sysctl."net.ipv6.icmp_echo_ignore_all" = true;

  # Ignore incoming ICMP redirects (note: default is needed to ensure that the
  # setting is applied to interfaces added after the sysctls are set)
  boot.kernel.sysctl."net.ipv4.conf.all.accept_redirects" = false;
  boot.kernel.sysctl."net.ipv4.conf.default.accept_redirects" = false;
  boot.kernel.sysctl."net.ipv4.conf.all.secure_redirects" = false;
  boot.kernel.sysctl."net.ipv4.conf.default.secure_redirects" = false;
  boot.kernel.sysctl."net.ipv6.conf.all.accept_redirects" = false;
  boot.kernel.sysctl."net.ipv6.conf.default.accept_redirects" = false;

  # Ignore outgoing ICMP redirects (this is ipv4 only)
  boot.kernel.sysctl."net.ipv4.conf.all.send_redirects" = false;
  boot.kernel.sysctl."net.ipv4.conf.default.send_redirects" = false;

  # Disable TCP timestamps (leaks system time)
  boot.kernel.sysctl."net.ipv4.tcp_timestamps" = false;

  # Disable source routing (can be used for MITM)
  boot.kernel.sysctl."net.ipv4.conf.all.accept_source_route" = false;
  boot.kernel.sysctl."net.ipv4.conf.default.accept_source_route" = false;
  boot.kernel.sysctl."net.ipv6.conf.all.accept_source_route" = false;
  boot.kernel.sysctl."net.ipv6.conf.default.accept_source_route" = false;

  # Disable IPv6 router advertisements (can be used for MITM)
  boot.kernel.sysctl."net.ipv6.conf.all.accept_ra" = false;
  boot.kernel.sysctl."net.ipv6.conf.default.accept_ra" = false;

  # Enable IPv6 privacy extensions (IPv6 address are genereated from the MAC address which is fingerprintable)
  boot.kernel.sysctl."net.ipv6.conf.all.use_tempaddr" = 2;
}
