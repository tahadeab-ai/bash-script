#!/bin/bash
# ============================================================
# cleanup_checkpoints.sh
# الغرض: الاحتفاظ بأفضل أو أحدث N نماذج، وحذف الباقي
# الاستخدام: ./cleanup_checkpoints.sh [num_to_keep] [mode]
# mode: "latest" (افتراضي) أو "best" (حسب الدقة)
# ============================================================

set -e

KEEP=${1:-5}
MODE=${2:-"latest"}
CKPT_DIR=${CKPT_DIR:-"./checkpoints"}

if [ ! -d "$CKPT_DIR" ]; then
    echo "❌ المجلد غير موجود: $CKPT_DIR"
    exit 1
fi

cd "$CKPT_DIR"

echo "======================================================"
echo "🧹 تنظيف نقاط التفتيش في: $(pwd)"
echo "📌 الوضع: $MODE | الاحتفاظ بـ: $KEEP"
echo "======================================================"

TOTAL=$(ls -1 *.pt *.pth *.ckpt 2>/dev/null | wc -l)
echo "📊 إجمالي الملفات: $TOTAL"

if [ "$TOTAL" -le "$KEEP" ]; then
    echo "✅ لا يوجد ما يُحذف. العدد أقل من الحد."
    exit 0
fi

case "$MODE" in
    latest)
        echo ""
        echo "🗑️  حذف الأقدم مع الاحتفاظ بأحدث $KEEP ملفات..."
        # احتفظ بأحدث N ملفات، احذف الباقي
        ls -t *.pt *.pth *.ckpt 2>/dev/null | tail -n +$((KEEP + 1)) | while read -r f; do
            echo "   حذف: $f"
            rm -f "$f"
        done
        ;;
    best)
        echo ""
        echo "🗑️  حذف الأسوأ حسب الدقة (المفترض أن الاسم يحتوي على الرقم)..."
        # ملاحظة: هذا يفترض أن اسم الملف يحتوي على الدقة مثل model_acc_0.95.pt
        ls -1 *.pt 2>/dev/null | \
            awk -F'acc_|\.pt' '{print $2, $0}' | \
            sort -rn | tail -n +$((KEEP + 1)) | \
            awk '{$1=""; print $0}' | \
            while read -r f; do
                [ -n "$f" ] && rm -f "$f" && echo "   حذف: $f"
            done
        ;;
    *)
        echo "❌ وضع غير معروف: $MODE"
        exit 1
        ;;
esac

echo ""
echo "✅ اكتمل التنظيف."
echo "📂 الملفات المتبقية:"
ls -lh *.pt *.pth *.ckpt 2>/dev/null | awk '{print "   " $9 " (" $5 ")"}'
