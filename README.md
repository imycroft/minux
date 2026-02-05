# Minux
**Current version 2.0**

Minux is a minimal Linux distribution designed to run on both real hardware and virtual environments such as QEMU or VirtualBox with serial console support, I tried to make it as simple as possible, to keep minimal size
The system can run live or be installed **check the installation instruction**

## Kernel version
Kernel version 6.18.6

## Downloads

Prebuilt binaries are available in **GitHub Releases**.

- `minux-<version>.iso` – Bootable ISO with tty0 or ttyS0
- `minux-boot-<version>.tar.xz` – Compressed bundle containing:
  - `bzImage`
  - `initramfs.cpio.zst`

## Quick Start

### Boot the ISO

Use -nographic if you want a headless console; otherwise, you can omit the -nographic option.
```bash
qemu-system-x86_64 -cdrom minux-<`version`>.iso -nographic
```
When running under WSL1 or Termux, you must use the -nographic switch, otherwise the system will fail to display the console and may not function properly.

### Boot kernel + initramfs
```bash
tar -xJf minux-boot-<version>.tar.xz

qemu-system-x86_64 \
  -kernel bzImage \
  -initrd initramfs.cpio \
  -append "console=ttyS0" \
  -nographic
```
The -append "console=ttyS0" and -nographic options are only required when running in Termux or WSL1; on standard Linux or other virtual environments, they can be omitted.

## Install
From version 2.0 the system can be installed. if you don't have a disk, please see **Create the disk** section.

```bash
qemu-system-x86_64 -cdrom minux-<version>.iso -drive file=minux.img,format=raw
```

The disk will appear as 
```bash
/dev/sda
```

### Create the disk
There are several ways for creating the disk image, the minimum size recommended is 64M, as the whole system will take 15MB after installation is finished.
1. Using native commands
```bash
# create the disk
dd if=/dev/zero of=minux.img bs=1M count=64

# attach it as a loop device
sudo losetup -fP minux.img

# Find which loop device was assigned:
losetup -a
# Example result: /dev/loop0

# create a filesystem
sudo mkfs.ext4 /dev/loop0

# detach the loop
sudo losetup -d /dev/loop0
```
Now minux.img is a ready-to-use block device image.

**Skip 2 if you have already created the disk image using the method 1**

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

- login as root with no password
- type :
```bash
minux-install /dev/sda
```
Be carefull when running this command, as the whole minux.img will be erased and formated, press Y to confirm.
- after the installation finishes shutdown the system
```bash
poweroff
```

- start your newly installed system :
```bash
qemu-system-x86_64 -drive file=minux.img,format=raw -nographic
```
- enter your password as root

### Configuration of the doas command
If you want to run commands as root, while logged in as your user, follow these steps :
- edit the /etc/doas.conf file as root, you can install nano if you are not familiar with vi, bur running **apk add nano**
```bash
vi /etc/doas.conf
```
uncomment the line : # permit persist :wheel, by removing #

save and exit

#### Notes for vi
- press i to enter edit mode
- press ESC to leave edit mode
- press : to enter command mode
- press wq to save and exit

- add your username to the /etc/group file
```bash
vi /etc/group
```
add your username at the end of the line **wheel:x:10:** to be **wheel:x:10:your_user_name_here**

save and exit

- logout and login as your username, check you can doas :
```bash
doas whoami
```
You must see **root**



### 2.0 Release note

- Network access added, the eth0 is configured to connect using QEMU, so if you run the system using QEMU you can access internet
- **apk** is the default package manager, i had to choose between several package managers, I finished by adopting **apk**
- The system can run **live** or be **installed**

### Notes

- busybox contains the .config file
- linux-6.18.6 contains the .config file 

## How to Create the cpio archive
```bash
cd rootfs
find . | cpio -o -H newc | zstd -19 -T0 > ../initramfs.cpio.zst
```
I used zstd commpression to reduce the initramfs.cpio size

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
**Or**
### Create the iso 
From within the kernel folder (linux-6.18.6), run:
```bash
make isoimage FDARGS="initrd=/initramfs.cpio.zst console=tty0 console=ttyS0,115200" FDINITRD=/location/to/initramfs.cpio.zst
```

## Contribution to the project 
Contact me by email if you want to contribute to the project, or just to learn the how to
email:**w.hafid@gmail.com**