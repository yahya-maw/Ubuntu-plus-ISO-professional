#!/bin/bash
set -e # التوقف الفوري عند أي خطأ

echo "--- المرحلة 1: تحميل وفك الـ ISO ---"

# البحث الديناميكي عن الرابط لضمان عدم حدوث خطأ 404
BASE_URL="https://releases.ubuntu.com/24.04/"
ISO_FILE=$(curl -sL $BASE_URL | grep -Eo 'ubuntu-24\.04(\.[0-9]+)?-desktop-amd64\.iso' | head -n 1)
FULL_URL="${BASE_URL}${ISO_FILE}"

echo "جاري تحميل: $FULL_URL"
wget -q --show-progress -O original.iso "$FULL_URL"

# فك هيكل الـ ISO باستخدام xorriso (الطريقة الاحترافية)
mkdir -p source
sudo xorriso -osirrox on -indev original.iso -extract / source/
sudo chmod -R 777 source

# البحث عن ملف النظام الرئيسي (SquashFS) مهما كان اسمه (كبير أو صغير)
SQUASH_PATH=$(find source -iname "filesystem.squashfs")
echo "تم العثور على ملف النظام في: $SQUASH_PATH"

# فك قلب النظام للبدء في التعديل
sudo unsquashfs -d chroot_dir "$SQUASH_PATH"
echo "✅ تم تجهيز بيئة التعديل بنجاح."
