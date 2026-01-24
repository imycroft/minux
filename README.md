# Minux

Minux is a minimal Linux distribution designed for headless use and QEMU,
with serial console support.

## Downloads

Prebuilt binaries are available in **GitHub Releases**.

- `minux.iso` – Bootable ISO
- `minux-boot.tar.xz` – Compressed bundle containing:
  - `bzImage`
  - `initramfs.cpio`

## Quick Start

### Boot the ISO

```bash
qemu-system-x86_64 -cdrom minux.iso -m 512 -nographic
```
### Boot kernel + initramfs
```bash
tar -xJf minux-boot.tar.xz

qemu-system-x86_64 \
  -kernel bzImage \
  -initrd initramfs.cpio \
  -append "console=ttyS0" \
  -m 512 -nographic
```
### Note
Console output is on ttyS0

Designed to work in Termux and headless environments


