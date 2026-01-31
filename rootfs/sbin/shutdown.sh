#!/bin/sh
echo "Shutting down..."
sync
umount -a -r
poweroff -f
