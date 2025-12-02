{ ... }:
{
  # source https://github.com/CachyOS/CachyOS-Settings/blob/master/usr/lib/sysctl.d/99-cachyos-settings.conf
  # source https://github.com/LudovicoPiero/dotfiles/blob/main/cells/workstations/nixosProfiles/security/default.nix

  boot.kernel.sysctl = {
    # The sysctl swappiness parameter determines the kernel's preference for pushing anonymous pages or page cache to disk in memory-starved situations.
    # A low value causes the kernel to prefer freeing up open files (page cache), a high value causes the kernel to try to use swap space,
    # and a value of 100 means IO cost is assumed to be equal.
    "vm.swappiness" = 1;

    # The value controls the tendency of the kernel to reclaim the memory which is used for caching of directory and inode objects (VFS cache).
    # Lowering it from the default value of 100 makes the kernel less inclined to reclaim VFS cache (do not set it to 0, this may produce out-of-memory conditions)
    "vm.vfs_cache_pressure" = 50;

    # Contains, as a bytes of total available memory that contains free pages and reclaimable
    # pages, the number of pages at which a process which is generating disk writes will itself start
    # writing out dirty data.
    "vm.dirty_bytes" = 268435456;

    # page-cluster controls the number of pages up to which consecutive pages are read in from swap in a single attempt.
    # This is the swap counterpart to page cache readahead. The mentioned consecutivity is not in terms of virtual/physical addresses,
    # but consecutive on swap space - that means they were swapped out together. (Default is 3)
    # increase this value to 1 or 2 if you are using physical swap (1 if ssd, 2 if hdd)
    "vm.page-cluster" = 0;

    # Contains, as a bytes of total available memory that contains free pages and reclaimable
    # pages, the number of pages at which the background kernel flusher threads will start writing out
    # dirty data.
    "vm.dirty_background_bytes" = 134217728;

    # This tunable is used to define when dirty data is old enough to be eligible for writeout by the
    # kernel flusher threads.  It is expressed in 100'ths of a second.  Data which has been dirty
    # in-memory for longer than this interval will be written out next time a flusher thread wakes up
    # (Default is 3000).
    #vm.dirty_expire_centisecs = 3000

    # The kernel flusher threads will periodically wake up and write old data out to disk.  This
    # tunable expresses the interval between those wakeups, in 100'ths of a second (Default is 500).
    "vm.dirty_writeback_centisecs" = 1500;

    # This action will speed up your boot and shutdown, because one less module is loaded. Additionally disabling watchdog timers increases performance and lowers power consumption
    # Disable NMI watchdog
    "kernel.nmi_watchdog" = 0;

    # Enable the sysctl setting kernel.unprivileged_userns_clone to allow normal users to run unprivileged containers.
    "kernel.unprivileged_userns_clone" = 1;

    # To hide any kernel messages from the console
    "kernel.printk" = "3 3 3 3";

    # Restricting access to kernel pointers in the proc filesystem
    "kernel.kptr_restrict" = 2;

    # Disable Kexec, which allows replacing the current running kernel.
    "kernel.kexec_load_disabled" = 1;

    # Increase the maximum connections
    # The upper limit on how many connections the kernel will accept (default 4096 since kernel version 5.6):
    "net.core.somaxconn" = 8192;

    # Enable TCP Fast Open
    # TCP Fast Open is an extension to the transmission control protocol (TCP) that helps reduce network latency
    # by enabling data to be exchanged during the sender’s initial TCP SYN [3].
    # Using the value 3 instead of the default 1 allows TCP Fast Open for both incoming and outgoing connections:
    "net.ipv4.tcp_fastopen" = 3;

    # Enable BBR3
    # The BBR3 congestion control algorithm can help achieve higher bandwidths and lower latencies for internet traffic
    # "net.ipv4.tcp_congestion_control" = "bbr";

    # TCP SYN cookie protection
    # Helps protect against SYN flood attacks. Only kicks in when net.ipv4.tcp_max_syn_backlog is reached:
    "net.ipv4.tcp_syncookies" = 1;

    # TCP Enable ECN Negotiation by default
    "net.ipv4.tcp_ecn" = 1;

    # TCP Reduce performance spikes
    # Refer https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_for_real_time/7/html/tuning_guide/reduce_tcp_performance_spikes
    "net.ipv4.tcp_timestamps" = 0;

    # Increase netdev receive queue
    # May help prevent losing packets
    "net.core.netdev_max_backlog" = 16384;

    # Disable TCP slow start after idle
    # Helps kill persistent single connection performance
    "net.ipv4.tcp_slow_start_after_idle" = 0;

    # Protect against tcp time-wait assassination hazards, drop RST packets for sockets in the time-wait state. Not widely supported outside of Linux, but conforms to RFC:
    "net.ipv4.tcp_rfc1337" = 1;

    # Set the maximum watches on files
    "fs.inotify.max_user_watches" = 524288;

    # Set size of file handles and inode cache
    # "fs.file-max" = 2097152;

    # Disable core dumps
    "kernel.core_pattern" = "/dev/null";

    # The Magic SysRq key is a key combo that allows users connected to the
    # system console of a Linux kernel to perform some low-level commands.
    # Disable it, since we don't need it, and is a potential security concern.
    "kernel.sysrq" = 0;

    ## TCP hardening
    # Prevent bogus ICMP errors from filling up logs.
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
    # Reverse path filtering causes the kernel to do source validation of
    # packets received from all interfaces. This can mitigate IP spoofing.
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.conf.all.rp_filter" = 1;
    # Do not accept IP source route packets (we're not a router)
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    # Don't send ICMP redirects (again, we're on a router)
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
    # Refuse ICMP redirects (MITM mitigations)
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;

    ## TCP optimization
    # TCP Fast Open is a TCP extension that reduces network latency by packing
    # data in the sender’s initial TCP SYN. Setting 3 = enable TCP Fast Open for
    # both incoming and outgoing connections:
    # Bufferbloat mitigations + slight improvement in throughput & latency
    # "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "cake";
    "net.ipv4.tcp_retries2" = 5;

    # Disable core dumps for setuid programs to protect sensitive information.
    "fs.suid_dumpable" = 0;
  };

  boot.kernelModules = [ "tcp_bbr" ];
}
