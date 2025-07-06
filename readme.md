## Debian Trixie Standard Installation for StarFive VisionFive 2 Board

<p align="center">
    <img src="assets/visionfive2.png" alt="VisionFive 2 Board" style="width:80%;" />
</p>

### Project Directory Structure

```

├── bootstrap.sh
├── env.sh
├── mnt
│   ├── bootfs
│   └── rootfs
├── prepare.sh
├── readme.md
├── remount.sh
├── riscv64_setup.sh
├── run
│   
├── run_qemu.sh
├── setupfs.sh
└── template
    ├── 99-cpufreq.rules
    ├── fstab
    ├── resize-rootfs.service
    ├── resize-rootfs.sh
    └── uEnv.txt
```