# Minux

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

### Note

In release there are two iso files:
- minux-<`version`>.iso -> default console (tty0) to be used on standard linux, WSL2, or other virtual environments ;
- minux-serial.iso      -> serial console only (ttyS0) to be used on Termux or WSL1.




