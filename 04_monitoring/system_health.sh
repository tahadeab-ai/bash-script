#!/bin/bash
# ============================================================
# system_health.sh
# الغرض: فحص شامل لصحة الخادم قبل بدء التدريب
# الاستخدام: ./system_health.sh
# ============================================================

echo "======================================================"
echo "🏥 فحص صحة النظام — $(hostname)"
echo "⏰ $(date '+%Y-%m-%d %H:%M:%S')"
echo "======================================================"

# 1. المعالج
echo ""
echo "🧠 المعالج (CPU):"
echo "   النواة: $(nproc) cores"
uptime | awk -F'load average:' '{print "   متوسط التحميل:" $2}'

# 2. الذاكرة
echo ""
echo "💾 الذاكرة (RAM):"
free -h | awk 'NR==2 {print "   المستخدم: " $3 " / " $2 " (" int($3/$2*100) "%)"}'

# 3. القرص
echo ""
echo "💿 القرص الصلب:"
df -h / | awk 'NR==2 {print "   المستخدم: " $3 " / " $2 " (" $5 ")"}'
echo "   المساحة في المجلد الحالي:"
du -sh . 2>/dev/null | awk '{print "   " $1}'

# 4. GPU
echo ""
echo "🎮 كروت الشاشة:"
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=index,name,memory.used,memory.total,temperature.gpu,utilization.gpu \
        --format=csv,noheader | \
    awk -F', ' '{
        printf "   GPU %s: %s | ذاكرة %s/%s | %s°C | %s%%\n", $1, $2, $3, $4, $5, $6
    }'
else
    echo "   ⚠️ nvidia-smi غير متوفر"
fi

# 5. الشبكة
echo ""
echo "🌐 الشبكة:"
if ping -c 1 -W 3 8.8.8.8 &> /dev/null; then
    echo "   ✅ متصل بالإنترنت"
else
    echo "   ❌ لا يوجد اتصال بالإنترنت"
fi

# 6. تحذيرات
echo ""
echo "======================================================"
echo "⚠️  التحذيرات:"

# تحذير الذاكرة
MEM_USAGE=$(free | awk 'NR==2 {print int($3/$2*100)}')
[ "$MEM_USAGE" -gt 85 ] && echo "   ⚠️ الذاكرة مرتفعة ($MEM_USAGE%)"

# تحذير القرص
DISK_USAGE=$(df / | awk 'NR==2 {print int($5)}')
[ "$DISK_USAGE" -gt 85 ] && echo "   ⚠️ القرص ممتلئ ($DISK_USAGE%)"

# تحذير حرارة GPU
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader | while read -r temp; do
        [ "$temp" -gt 80 ] && echo "   ⚠️ حرارة GPU مرتفعة ($temp°C)"
    done
fi

[ "$MEM_USAGE" -le 85 ] && [ "$DISK_USAGE" -le 85 ] && echo "   ✅ كل شيء يعمل بشكل جيد"

echo "======================================================"
