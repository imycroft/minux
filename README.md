# Minux
**Current version 1.2**
Minux is a minimal Linux distribution designed to run on both real hardware and virtual environments such as QEMU or VirtualBox with serial console support, I tried to make it as simple as possible, to keep minimal size
The system is based on initramfs (BusyBox) as user space, and a tiny kernel configuration.

## Kernel version
Kernel version 6.18.6

## Downloads

Prebuilt binaries are available in **GitHub Releases**.

- `minux-<version>.iso` – Bootable ISO with default console
- `minux-serial-<version>.iso` – Bootable ISO with ttyS0, for Termux and WSL1 use
- `minux-boot.tar.xz` – Compressed bundle containing:
  - `bzImage`
  - `initramfs.cpio`

## Quick Start

### Boot the ISO

Use -nographic if you want a headless console; otherwise, you can omit the -nographic option.
```bash
qemu-system-x86_64 -cdrom minux-<`version`>.iso -m 512 -nographic
```
When running under WSL1 or Termux, you must use the -nographic switch, otherwise the system will fail to display the console and may not function properly.

### Boot kernel + initramfs
```bash
tar -xJf minux-boot.tar.xz

qemu-system-x86_64 \
  -kernel bzImage \
  -initrd initramfs.cpio \
  -append "console=ttyS0" \
  -m 512 -nographic
```
The -append "console=ttyS0" and -nographic options are only required when running in Termux or WSL1; on standard Linux or other virtual environments, they can be omitted.

### Boot using persistence
From version 1.2 the system supports adding a hard drive.
- For the iso version :
```bash
qemu-system-x86_64 -cdrom minux.iso -drive file=disk.img
```

- For the kernel + initramfs version
```bash
qemu-system-x86_64 -kernel bzImage -initrd initramfs.cpio -drive file=disk.img
```
The system automatically detects and mount the disk on /root, the disk will appear as 
```bash
/dev/sda
```
**The /root folder is persistent now.**

**In order to flush changes to the disk, you must shutdown the system with the command** 
```bash
poweroff -f
```
### Create the disk
There are several ways for creating the disk image
1. Using native commands
```bash
# create the 8MB disk
dd if=/dev/zero of=disk.img bs=1M count=8

# attach it as a loop device
sudo losetup -fP disk.img

# Find which loop device was assigned:
losetup -a
# Example result: /dev/loop0

# create a filesystem
sudo mkfs.ext4 /dev/loop0

# detach the loop
sudo losetup -d /dev/loop0
```
Now disk.img is a ready-to-use block device image.

2. Using QEMU
qcow2 format
```bash
qemu-img create -f qcow2 disk.qcow2 8M
```
Or raw
```bash
qemu-img create -f raw disk.img 8M
```

**Format the disk as previously shown in creating the disk with native commands**

Add format=qcow2 or raw in **-drive** switch depending on your choice

**-drive file=disk.qcow2,format=qcow2**

**-drive file=disk.img,format=raw**

### Note

In release there are two iso files:
- minux-<`version`>.iso -> default console (tty0) to be used on standard linux, WSL2, or other virtual environments ;
- minux-serial.iso      -> serial console only (ttyS0) to be used on Termux or WSL1.




