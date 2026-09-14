#!/bin/bash
# ============================================================
# log_analyzer.sh
# الغرض: استخراج إحصائيات من سجلات التدريب
# الاستخدام: ./log_analyzer.sh logs/train.log
# ============================================================

set -e

LOG_FILE=${1:-"logs/train.log"}

if [ ! -f "$LOG_FILE" ]; then
    echo "❌ الملف غير موجود: $LOG_FILE"
    exit 1
fi

echo "======================================================"
echo "📊 تحليل السجل: $LOG_FILE"
echo "======================================================"

# 1. إحصائيات عامة
echo ""
echo "📈 إحصائيات عامة:"
echo "   عدد الأسطر: $(wc -l < "$LOG_FILE")"
echo "   حجم الملف: $(du -h "$LOG_FILE" | cut -f1)"

# 2. آخر قيمة خسارة
echo ""
echo "📉 آخر 5 قيم Loss:"
grep -i "loss" "$LOG_FILE" | tail -n 5 || echo "   لا توجد قيم loss"

# 3. أفضل دقة
echo ""
echo "🏆 أعلى دقة مسجلة:"
grep -i "accuracy\|acc" "$LOG_FILE" | \
    awk '{print $NF}' | tr -d '%' | \
    sort -rn | head -n 1 | \
    awk '{print "   " $1 "%"}' || echo "   لا توجد دقة مسجلة"

# 4. الأخطاء
echo ""
echo "❌ عدد الأخطاء:"
ERRORS=$(grep -ci "error\|exception\|traceback" "$LOG_FILE" || echo "0")
echo "   $ERRORS خطأ"

if [ "$ERRORS" -gt 0 ]; then
    echo ""
    echo "🔍 آخر 3 أخطاء:"
    grep -i "error\|exception\|traceback" "$LOG_FILE" | tail -n 3
fi

# 5. التحذيرات
echo ""
echo "⚠️  عدد التحذيرات:"
grep -ci "warning\|warn" "$LOG_FILE" || echo "   0"

# 6. الزمن
echo ""
echo "⏱️  معلومات الزمن:"
FIRST=$(head -n 1 "$LOG_FILE" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -n 1)
LAST=$(tail -n 1 "$LOG_FILE" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -n 1)
[ -n "$FIRST" ] && echo "   البداية: $FIRST"
[ -n "$LAST" ] && echo "   النهاية: $LAST"

echo ""
echo "✅ انتهى التحليل."
