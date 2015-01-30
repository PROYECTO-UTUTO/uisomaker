#!/bin/bash
mkdir image/proc
mount -t proc proc image/proc
chroot image
umount image/proc
rm -rf image/proc
