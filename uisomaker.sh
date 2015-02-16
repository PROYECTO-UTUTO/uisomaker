#!/bin/bash
#################################################
#	UISOMake - Personalize ISO		#
#	~~~~~~~~~~~~~~~~~~~~~~~~~~		#
#						#
#	Version:	0.5			#
#	Date:		02/13/2015		#
#	License:	GPL3 or later		#
#	Author:		Diego G. Calbo		#
#	Email:		dgcalbo@gmail.com	#
#						#
#	Script based in:			#
#	Daniel Olivera's and			#
#	Galleguindio's scripts			#
#################################################

#################################
#	Verify ROOT user	#
#################################

if [[ $EUID -ne 0 ]]
then
	clear
	echo "You must be ROOT." 1>&2
	echo "Do you want to continue? (y/n)"
	read answer
	if [[ $answer == [yY] ]]
	then
		sudo bash $0
	else
		clear
		echo "Bye bye!"
		sleep 3
		clear
	fi
	exit 0
else
	clear
	echo "You're ROOT!!!"
	echo "Be carefully!!!"
	sleep 3
fi

#########################
#	Functions	#
#########################

function create() {
	clear
	if [ ! -d "$XS" ] || [ ! -d "$XS/cdimage" ] || [ ! -d "$XS/image" ]
	then
		echo "Creating '$XS' directory."
		mkdir -p $XS
		echo "Done!"
		echo "Creating '$XS/cdimage' directory."
		mkdir -p $XS/cdimage
		echo "Done!"
		echo "Creating '$XS/image' directory."
		mkdir -p $XS/image
		echo "Done!"
		echo ""
		echo "Environment created!"
	else
		echo -e "Nothing is done.\nThe environment was created!"
	fi
	echo ""
	echo -e "INFORMATION\n==========="
	echo "Directories created:"
	echo $XS
	echo $XS/cdimage
	echo $XS/image
	echo ""
}

function delete() {
	clear
	if [ -d "$XS" ]
	then
		echo "Deleting '$XS' directory."
		rm -rf $XS
		echo "Done!"
		echo ""
		echo "Environment deleted!"
	else
		echo -e "Nothing is done.\nThe environment was ready!"
	fi
	echo ""
}

function mount_source() {
	clear
	if [ ! -d "/mnt/UISOMaker/XS-VIVO" ]
	then
		echo "Creating mount directory."
		mkdir -p /mnt
		mkdir -p /mnt/UISOMaker
		mkdir -p /mnt/UISOMaker/XS-VIVO
		echo "Done!"
		echo ""
		echo -e "INFORMATION\n==========="
		echo "Directory created:"
		echo "/mnt/UISOMaker/XS-VIVO"
	fi
	echo ""
	read -p "Select path to the original file ISO: " path
	echo "Mounting the original ISO."
	mount -t iso9660 -o loop $path /mnt/UISOMaker/XS-VIVO
	echo "Done!"
	echo ""
}

function mount_squashfs() {
	clear
	if [ ! -d "/mnt/UISOMaker/XSimage" ]
	then
		echo "Creating mount directory."
		mkdir -p /mnt
		mkdir -p /mnt/UISOMaker
		mkdir -p /mnt/UISOMaker/XSimage
		echo "Done!"
		echo ""
		echo -e "INFORMATION\n==========="
		echo "Directory created:"
		echo "/mnt/UISOMaker/XSimage"
	fi
	echo ""
	echo "Mounting the squashfs image."
	mount -t squashfs -o loop /mnt/UISOMaker/XS-VIVO/image.squashfs /mnt/UISOMaker/XSimage
	echo "Done!"
	echo ""
}

function umount_sources() {
	clear
	echo "Umounting /mnt/UISOMaker/XSimage"
	umount /mnt/UISOMaker/XSimage
	echo "Done!"
	echo "Umounting /mnt/UISOMaker/XS-VIVO"
	umount /mnt/UISOMaker/XS-VIVO
	echo "Done!"
	echo "Deleting /mnt/UISOMaker"
	rm -rf /mnt/UISOMaker
	echo "Done!"
	echo ""
}

function copyto_cdimage() {
	clear
	echo "Starting copying files from /mnt/UISOMaker/XS-VIVO to $XS/cdimage"
	echo ""
	sleep 1
	cp_progress /mnt/UISOMaker/XS-VIVO $XS/cdimage
	echo ""
	echo "Done!"
	echo ""
}

function copyto_image() {
	clear
	echo "Starting copying files from /mnt/UISOMaker/XSimage to $XS/image"
	echo ""
	sleep 1
	cp_progress /mnt/UISOMaker/XSimage $XS/image
	echo ""
	echo "Done!"
	echo ""
}

function cp_progress()
{
	cp -a $1/* $2 2>/dev/null &
	job=$!
	start=$(date +%s)
	delay=0.5
	spinstr='|/-\'
	clear
	while [ "$(ps a | awk '{print $1}' | grep $job)" ]
	do
		temp=${spinstr#?}
		now=$(date +%s)
		elapse=$(($now - $start))
		printf " [%c]  Copying... Elapsed Time %02dm %02ds" "$spinstr" "$(($elapse / 60))" "$(($elapse % 60))"
		spinstr=$temp${spinstr%"$temp"}
		sleep $delay
		printf "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"
	done
	clear
	printf "Copied %s files in %02dm %02ds" "$((`find $2 -type f | wc -l`))" "$(($elapse / 60))" "$(($elapse % 60))"
}

function chroot_image() {
	clear
	mkdir -p $XS/image/proc
	declare -a puntos=('proc' 'sys' 'dev')
	i=0
	while [ $i -lt ${#puntos[*]} ]
	do
		echo "Mounting ${puntos[$i]}..."
		mkdir -p $XS/image/${puntos[$i]}
		mount -o bind /${puntos[$i]} $XS/image/${puntos[$i]}/
		if [ $? -eq 0 ]
		then
			let i=i+1
			sleep 1
			continue;
		else
			echo "Failed to mount ${puntos[$i]}... Aborting!"
			sleep 1
			exit 1;
		fi
	done
	echo "Done!"
	sleep 1
	clear
	echo "Entying to 'chroot' mode."
	echo "When you finish, write 'exit' in the console."
	echo "Press any key to coninuar."
	read key
	chroot $XS/image
	clear
	echo "Exiting from 'chroot' mode."
	i=0
	while [ $i -lt ${#puntos[*]} ]
	do
		echo "Umounting ${puntos[$i]}..."
		umount $XS/image/${puntos[$i]}/
		if [ $? -eq 0 ]
		then
			let i=i+1
			sleep 1
			continue;
		else
			echo "Failed to umount ${puntos[$i]}... Aborting!"
			sleep 1
			exit 1;
		fi
	done
	echo "Done!"
	#rm -rf $XS/image/proc
	sleep 1
	clear
	echo "Welcome back!!!"
	echo "You're in your REAL SYSTEM, be carefully."
}

function new_version() {
	clear
	echo "The actual ISO version is:	`cat $XS/image/ututo.lastversion`"
	echo ""
	read -p "Write the new ISO version:	" nversion
	echo $nversion > $XS/image/ututo.lastversion
	echo ""
	echo "The new ISO version is:		`cat $XS/image/ututo.lastversion`"
	sleep 1
	echo ""
	echo "Done!"
	sleep 1
}

function purge() {
	clear
	echo "Not yet funtional!"
	sleep 1
}

function usage() {
	uso="Uso:\n\nMontar: sudo bash $0 -m\nDesmontar: sudo bash $0 -d"
	echo -e $uso
}

#########################
#	Variables	#
#########################

WORKAREA="$HOME/.uisomaker/workarea.txt"
XS=`cat $WORKAREA`'/XS'

#########################################################
#	Create preferences directory if not exists	#
#########################################################

mkdir -p ~/.uisomaker

#################################################
#	Verify or Create workarea's file	#
#################################################

if [ ! -f "$WORKAREA" ]
then
	clear
	echo "The work area isn't configure."
	echo "Do you want configure the work area? (y/n):" 
	read answer
	if [[ $answer != [yY] ]]
	then
		clear
		echo "Bye bye!"
		sleep 3
		exit 0
	fi
	answer="n"
	while [ "${answer}" = n ]
	do
		echo "Please, write the path to workarea."
		read path
		echo -n "The path $path is correct? (y/n)"
		read answer
	done
	echo $path > $WORKAREA
	XS=`cat $WORKAREA`'/XS'
fi

#########################
#	UISOMaker Menu	#
#########################

while [ answer != "0" ]  
do 
	clear 
	echo -e "\e[0m=== UISOMaker Menu ==="
	echo ""
	if [ -d "$XS/cdimage" ] && [ -d "$XS/image" ]
	then
		echo -e " 0	Create environment for copies		\e[1;42mDone!\e[0m"
	else
		echo " 0	Create environment for copies"
	fi
	
	if ls -1 /mnt/UISOMaker/XS-VIVO/* >/dev/null 2>&1
	then
		echo -e " 1	Mount ISO source			\e[1;42mDone!\e[0m"
	else
		echo " 1	Mount ISO source"
	fi
	if ls -1 /mnt/UISOMaker/XSimage/* >/dev/null 2>&1
	then
		echo -e " 2	Mount image squahfs			\e[1;42mDone!\e[0m"
	else
		echo " 2	Mount image squahfs"
	fi
	if ls -1 $XS/cdimage/* >/dev/null 2>&1
	then
		echo -e " 3	Copy ISO source files to 'cdimage'	\e[1;42mDone!\e[0m"
	else
		echo " 3	Copy ISO source files to 'cdimage'"
	fi
	if ls -1 $XS/image/* >/dev/null 2>&1
	then
		echo -e " 4	Copy image squash files to 'image'	\e[1;42mDone!\e[0m"
	else
		echo " 4	Copy image squash files to 'image'"
	fi
	echo " 5	Umount original files"
	echo " 6	Make chroot" 
	echo " 7	Put new ISO version"
	echo " 8	Purge of the 'image' directories"
	echo " 9	Make squashfs" 
	echo " 10	Make ISO"
	echo " u	Usage"
	echo " q	Exit" 
	echo ""
	read -p " Option: " answer 
	case $answer in 
		0) create ;; 
		1) mount_source ;;
		2) mount_squashfs ;;
		3) copyto_cdimage ;;
		4) copyto_image ;;
		5) umount_sources ;;
		6) chroot_image ;;
		7) new_version ;;
		U|u) usage ;;
		Q|q) break ;;
		A|a) echo "enter zip archive name (eyymmdd)" 
		read name 
		cd /disks/E/ 
		zip -r /disks/G/$name.zip * 
		cd ~/ 
		;; 
		*) answer=0 ;; 
	esac  
	echo "press RETURN for menu o 'q' for exit" 
	read key 
done 
exit 0
