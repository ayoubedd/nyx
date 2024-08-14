{ ... }: {
  boot.kernel.sysctl = {
    "fs.xfs.xfssyncd_centisecs" = 10000; # increase writeback interval
  };
}
