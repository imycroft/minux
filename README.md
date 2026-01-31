# Minux
**Current version 1.4**

Minux is a minimal Linux distribution designed to run on both real hardware and virtual environments such as QEMU or VirtualBox with serial console support, I tried to make it as simple as possible, to keep minimal size
The system is based on initramfs (BusyBox) as user space, and a tiny kernel configuration.

## Kernel version
Kernel version 6.18.6

## Downloads

Prebuilt binaries are available in **GitHub Releases**.

- `minux-<version>.iso` – Bootable ISO with tty0 or ttyS0
- `minux-boot-<version>.tar.xz` – Compressed bundle containing:
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
tar -xJf minux-boot-<version>.tar.xz

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
qemu-system-x86_64 -cdrom minux-<version>.iso -drive file=disk.img
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

### Login
**root** or **user** with **no password**

### 1.4 Release note

- busybox is now dynamically linked with musl
- musl lib added /lib/ld-musl-x86_64.so.1
- ldd command added

### Notes
minux direcotries added
- rootfs contains the system
- busybox contains the .config file
- linux-6.16.6 contains the .config file + the bzImage (kernel)

## Create the cpio archive
```bash
cd rootfs
find . | cpio -o -H newc > ../initramfs.cpio
```
## Compile the linux kernel
- Download or clone the linux kernel & extract it
- Copy the config file to use the same config as minux
```bash
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.18.8.tar.xz
tar xvf linux-6.18.8.tar.xz
cp linux-6.18.6/.config linux-6.18.8/
cd linux-6.18.8
```
- If you want you can check the configuration by running 
**make sure you inside the linux-6.18.8 folder before running these commands**
```bash
make menuconfig
```
- Compile the kernel
```bash
make -j$(nproc)
```
- Copy the resulting kernel to minux folder
```bash
cp arch/x86/boot/bzImage ../
```
- Now you can use the commands above (section **Boot kernel + initramfs**) to start the system.



