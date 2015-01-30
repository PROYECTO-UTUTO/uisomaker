# #!/bin/sh

# NAME: make-iso.sh

# Creates an iso9660 image with rockridge extensions from the contents
# of directory cdimage.

# VERSION es el nombre del iso generado
VERSION="UTUTO-XS-Custom-Vivo"
VERSIONCD="UTUTO-XS-Custom-Vivo!"

sync
sync
sync
CDIMAGE=cdimage
CDIMAGE2=cdimage/image.squashfs
if [ ! -d $CDIMAGE ];then
   echo "You need to be cd'd to the directory above 'cdimage'"
   exit
fi

ISO=pbcd.iso

rm $VERSION.iso
mkisofs -allow-limited-size -r -l -J -V $VERSIONCD -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot \
 -boot-load-size 4 -boot-info-table \
 -v -o $VERSION.iso $CDIMAGE

## rm -f $CDIMAGE2
echo "ISO generated in $VERSION.iso"
sync
sync
sync
