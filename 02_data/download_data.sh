#!/bin/bash
# ============================================================
# download_data.sh
# الغرض: تحميل مجموعات البيانات من مصادر مختلفة مع استكمال التحميل
# الاستخدام: ./download_data.sh [dataset_name] [url]
# ============================================================

set -e

DATA_DIR="${DATA_DIR:-./data/raw}"
DATASET_NAME=${1:-"dataset"}
URL=${2:-""}

mkdir -p "$DATA_DIR"
cd "$DATA_DIR"

echo "📥 تحميل: $DATASET_NAME"
echo "🔗 الرابط: $URL"

if [ -z "$URL" ]; then
    echo "❌ لم يتم تحديد رابط. الاستخدام: $0 [name] [url]"
    exit 1
fi

# استخدام wget مع خاصية الاستكمال (-c) وإعادة المحاولة
wget -c --tries=5 --waitretry=5 --progress=bar:force "$URL" -O "${DATASET_NAME}.download"

echo "✅ تم التحميل. جاري التحقق..."

# فك الضغط تلقائياً حسب الامتداد
FILE="${DATASET_NAME}.download"
case "$URL" in
    *.tar.gz|*.tgz)
        echo "📦 فك ضغط TAR.GZ..."
        tar -xzvf "$FILE"
        ;;
    *.tar)
        tar -xvf "$FILE"
        ;;
    *.zip)
        echo "📦 فك ضغط ZIP..."
        unzip -o "$FILE"
        ;;
    *.gz)
        gunzip "$FILE"
        ;;
    *)
        echo "⚠️ امتداد غير معروف. الملف محفوظ كـ: $FILE"
        ;;
esac

echo "✅ اكتمل التحميل والفك في: $(pwd)"
du -sh .
