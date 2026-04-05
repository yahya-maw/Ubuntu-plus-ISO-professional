#!/bin/bash
set -e

echo "--- المرحلة 2: تعديل قلب النظام (Chroot) ---"

# ربط المسارات الحيوية لضمان عمل الإنترنت والبرامج داخل البيئة المعزولة
sudo mount --bind /dev chroot_dir/dev
sudo mount --bind /run chroot_dir/run
sudo mount -t proc /proc chroot_dir/proc
sudo mount -t sysfs /sys chroot_dir/sys
sudo cp /etc/resolv.conf chroot_dir/etc/

# الدخول لقلب النظام لتنفيذ الأوامر
sudo chroot chroot_dir /bin/bash << 'EOF'
set -e
export DEBIAN_FRONTEND=noninteractive

# 1. تحديث المستودعات وإضافة الأدوات الأساسية
apt-get update
apt-get install -y software-properties-common curl wget gnupg rsync

# 2. إضافة مستودعات البرامج المطلوبة (Waydroid, Wine, MX)
curl -s https://repo.waydro.id | bash
add-apt-repository ppa:mx-linux/mx-tools -y
dpkg --add-architecture i386
mkdir -pm755 /etc/apt/keyrings
wget -O - https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor | tee /etc/apt/keyrings/winehq-archive.key > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/winehq-archive.key] https://dl.winehq.org/wine-builds/ubuntu/ noble main" | tee /etc/apt/sources.list.d/winehq.list

apt-get update

# 3. تثبيت حزمة الـ HP G62 الاحترافية
# تشمل Intel Drivers، XFCE، والبرامج الأساسية
apt-get install -y xubuntu-desktop waydroid winehq-staging \
                   mx-apps mx-tools synaptic zram-config htop \
                   xserver-xorg-video-intel mesa-utils libegl1-mesa

# 4. إعداد مجلد التحميلات (Downloads) لضمان عدم المسح
mkdir -p /etc/skel/Downloads
# جعل إعدادات المتصفح والنظام تعتبر هذا المجلد هو المرجع الدائم
echo 'XDG_DOWNLOAD_DIR="$HOME/Downloads"' > /etc/skel/.config/user-dirs.dirs

# 5. ضبط أداء الرامات (ZRAM) لتناسب مواصفات جهازك
echo "ALGO=lz4" >> /etc/default/zramswap
echo "vm.swappiness=150" >> /etc/sysctl.conf

# تنظيف الملفات المؤقتة لتقليل حجم الـ ISO
apt-get autoremove -y
apt-get clean
exit
EOF

# فك الارتباط الآمن بعد الانتهاء
sudo umount -l chroot_dir/dev
sudo umount -l chroot_dir/run
sudo umount -l chroot_dir/proc
sudo umount -l chroot_dir/sys
