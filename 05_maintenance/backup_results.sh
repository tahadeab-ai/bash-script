#!/bin/bash
# ============================================================
# backup_results.sh
# الغرض: نسخ احتياطي محلي ومزامنة مع خادم بعيد أو S3
# الاستخدام: ./backup_results.sh [destination]
# ============================================================

set -e

SOURCE_DIR=${SOURCE_DIR:-"./output"}
LOCAL_BACKUP_DIR=${LOCAL_BACKUP_DIR:-"./backups"}
REMOTE_DEST=${1:-""}
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

mkdir -p "$LOCAL_BACKUP_DIR"

echo "======================================================"
echo "💾 نسخ احتياطي — $TIMESTAMP"
echo "======================================================"

# 1. نسخة محلية مضغوطة
echo ""
echo "📦 إنشاء نسخة محلية مضغوطة..."
ARCHIVE="$LOCAL_BACKUP_DIR/backup_$TIMESTAMP.tar.gz"
tar -czvf "$ARCHIVE" "$SOURCE_DIR" 2>/dev/null || true

if [ -f "$ARCHIVE" ]; then
    echo "✅ تم إنشاء: $ARCHIVE ($(du -h "$ARCHIVE" | cut -f1))"
fi

# 2. مزامنة مع خادم بعيد (rsync)
if [ -n "$REMOTE_DEST" ]; then
    echo ""
    echo "🌐 مزامنة مع: $REMOTE_DEST"
    rsync -avz --progress "$SOURCE_DIR/" "$REMOTE_DEST/" 
    echo "✅ تمت المزامنة."
fi

# 3. حذف النسخ الأقدم من 7 أيام
echo ""
echo "🗑️  حذف النسخ الأقدم من 7 أيام..."
find "$LOCAL_BACKUP_DIR" -name "backup_*.tar.gz" -mtime +7 -delete
echo "✅ تم التنظيف."

# 4. عرض النسخ الموجودة
echo ""
echo "📂 النسخ الاحتياطية الحالية:"
ls -lh "$LOCAL_BACKUP_DIR"/*.tar.gz 2>/dev/null || echo "   لا توجد نسخ."

echo ""
echo "✅ اكتمل النسخ الاحتياطي."
