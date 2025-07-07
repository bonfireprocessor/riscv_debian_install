## Debian Trixie Standard Installation for StarFive VisionFive 2 Board

<p align="center">
    <img src="assets/visionfive2.png" alt="VisionFive 2 Board" style="width:70%;" />
</p>


### Abstract
Debian Trixie supports most parts of the VisionFive 2 board with the standard riscv64 distribtuion kernel, but the Debian installer cannot be diretly used with the VisionFive2 board. It seems to work with some tweaking, but this Repository shows a different way:
* It creates SD Image with the OS wich can be written to an SD card. It should work out-of-the-box with the the latest U-Boot Firmware of the VisionFive 2 board, at least with my board it was possible. If you have a board with an older Firmware there are instructions in the "VisionFive 2 Single Board Computer quick start guide" how to update the Firmware.
It is also possible to install U-Boot SPL and U-Boot Firmware on the partitions 0 and 1 of the SD card image and set the Dip Switches on the VisionFive 2 to SD Card boot. Than the VisionFive2 loads the matching Firmware from SD Card at every boot.

* The SD Image can be written to a SD Card with at least 4GB size with either the DD command or specialized programs like Balena Etcher in Windows. It is recommended to use an SD Card with at least 8GB.

* The Image can also directly be written on an NVMe SSD or eMMC Flash, it does not contain hard coded device names (like /dev/mmcblk0p4), so it can boot form every suitable boot device

* During the first boot the the Root file system is automatically resized to span the full device. 






### Upstream Status

For the latest upstream status of the VisionFive 2 board in the DabianLinux kernel, see the [https://wiki.debian.org/InstallingDebianOn/StarFive/VisionFiveV2](https://wiki.debian.org/InstallingDebianOn/StarFive/VisionFiveV2).

Currently the Kernel supports everything which is needed for "headless" operation as e.g. mini server.

* PCIe (including NVMe and the onboard VL805 PCIe xHCI USB Controller)
* USB 3.0
* Both Onboard Gigabit Ethernet Ports
* libsensor support for the SoC Thermal Sensors
* CPU frequency scaling





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