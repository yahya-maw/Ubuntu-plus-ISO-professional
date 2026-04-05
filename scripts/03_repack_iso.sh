#!/bin/bash
set -e

echo "--- المرحلة 3: التغليف النهائي ---"

# مسح ملف النظام القديم واستبداله بالجديد المعدل
SQUASH_PATH=$(find source -iname "filesystem.squashfs")
sudo rm "$SQUASH_PATH"

# ضغط النظام الجديد (أعلى درجة ضغط مستقرة)
sudo mksquashfs chroot_dir "$SQUASH_PATH" -comp zstd -b 1M -noappend

# تحديث حجم النظام في ملفات الـ ISO
sudo chmod +w source/casper/filesystem.size || true
printf $(sudo du -sx --block-size=1 chroot_dir | cut -f1) | sudo tee source/casper/filesystem.size

# تجميع الـ ISO النهائي
mkdir -p output
sudo xorriso -as mkisofs -r -V "Ubuntu-G62-Pro" -o output/Ubuntu-G62-Final.iso source/

echo "✅ اكتملت العملية. الملف جاهز في مجلد output."
