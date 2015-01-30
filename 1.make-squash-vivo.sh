#!/bin/bash
# Liberado bajo GPL-2 o posterior
#
# En el directorio "source" debe estar el filesystem
# a comprimir y convertir
# El directorio "cdimage" debe estar la estructura booteable
# del CD
#

rm cdimage/image.squashfs
sync
sync
sync
clear 
echo "borrar contenido /tmp /var/tmp y archivos en /"
echo "borrar contenido de archivos de /var/run/pulse"
echo "verificar directorio /root"
echo "verificar /var/log que este todo en cero bytes"
echo "vaciar /usr/portage/packages (menos el dir:  profiles)"
echo "vaciar /etc/uget/version y /opt/stages/etc/uget"
echo "vaciar /var/db/uget/ (/opt/rom/db/uget)"
echo "verificar el archivo /etc/uget/ututo-get.conf para que el procesador sea NONE (/opt/stages/etc/uget)"
echo "borrar todos los archivos *cfg0* de /etc"
echo "borrar /proc"
echo "borrar archivos no necesarios de /etc/X11"
echo "copiar contenido de /opt/rom/etc primero y luego /etc (sobreescribe) en /opt/stages/etc"
echo "verificar enlace /var/www/localhost/htdocs apuntando a /mnt/cdrom/InstallXS/htdocs"
echo "instalar los kernel en /boot /lib/modules y /usr/src"
echo "borrar contenido de /opt/stages/usr/src"
echo "borrar los otros /etc/lilo.conf /etc/skel.skel"
echo "enlace /etc/skel apunta a /opt/rom/etc/skel (copiar el dir primero)"
echo "quitar todo menos upate- y ututo- de /etc/cron.daily no de /opt/stages/etc/cron.daily"
echo "quitar los enlaces de syslog-ng y vixie-cron en /etc/runlevels/default pero no de /etc/stages/etc/runlevels/default"
echo " "
echo "Modificar el /etc/conf.d/local para que se adapte al liveCD (installXS)"
echo "tambien borrar los local.* de /opt/rom/etc/conf.d y /opt/stages/etc/conf.d"
echo "Poner rc_device_tarball="YES" en /opt/stages/etc/rc.conf \"no\" en /etc"
echo "export SSD_NICELEVEL=\"-19\" en /etc/rc.conf y \"-5\" en /opt/stages/etc/rc.conf"
echo " "
echo "Si ha realizado todo esto presione [ENTER]"
read -t 10000

mksquashfs image cdimage/image.squashfs -b 1048576 -always-use-fragments -comp xz
# -no-duplicates
# -check_data
