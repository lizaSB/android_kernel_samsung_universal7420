#!/system/bin/sh

mount -o remount,rw /system

# Inject SuperSU
if [ ! -f /system/xbin/su ]; then
	# Make necessary folders
	mkdir /system/etc/init.d

	# Extract SU from ramdisk to correct locations
	rm -rf /system/bin/app_process
	rm -rf /system/bin/install-recovery.sh
	cp /sbin/su/supolicy /system/xbin/
	cp /sbin/su/su /system/xbin/
	cp /sbin/su/libsupol.so /system/lib64/
	cp /sbin/su/install-recovery.sh /system/etc/
	cp /sbin/su/99SuperSUDaemon /system/etc/init.d/

	# Begin SuperSU install process
	cp /system/xbin/su /system/xbin/daemonsu
	cp /system/xbin/su /system/xbin/sugote
	cp /system/bin/sh /system/xbin/sugote-mksh
	mkdir -p /system/bin/.ext
	cp /system/xbin/su /system/bin/.ext/.su

	cp /system/bin/app_process64 /system/bin/app_process_init
	mv /system/bin/app_process64 /system/bin/app_process64_original

	echo 1 > /system/etc/.installed_su_daemon

	chmod 755 /system/xbin/su
	chmod 755 /system/xbin/daemonsu
	chmod 755 /system/xbin/sugote
	chmod 755 /system/xbin/sugote-mksh
	chmod 755 /system/xbin/supolicy
	chmod 777 /system/bin/.ext
	chmod 755 /system/bin/.ext/.su
	chmod 755 /system/bin/app_process_init
	chmod 755 /system/bin/app_process64_original
	chmod 644 /system/lib64/libsupol.so
	chmod 755 /system/etc/install-recovery.sh
	chmod 644 /system/etc/.installed_su_daemon
	
	ln -s /system/etc/install-recovery.sh /system/bin/install-recovery.sh
	ln -s /system/xbin/daemonsu /system/bin/app_process
	ln -s /system/xbin/daemonsu /system/bin/app_process64

	/system/xbin/su --install
	chmod 755 /system/xbin/busybox
	/system/xbin/busybox --install -s /system/xbin
fi

# DRM Video fix
if [ ! -f /system/lib/liboemcrypto.so.bak ]; then
	mv /system/lib/liboemcrypto.so /system/lib/liboemcrypto.so.bak
fi
		
# Enforce init.d script perms on any post-root added files
chmod 755 /system/etc/init.d
chmod 755 /system/etc/init.d/*

# Run init.d scripts
mount -t rootfs -o remount,rw rootfs
run-parts /system/etc/init.d

#  Wait for 3 seconds from boot before starting the SuperSU daemon
sleep 3
/system/xbin/daemonsu --auto-daemon &

sync
