#!/bin/bash
# ============================================================
# monitor_gpu.sh
# الغرض: مراقبة GPU والعمليات الجارية في لوحة محدثة
# الاستخدام: ./monitor_gpu.sh [refresh_seconds]
# ============================================================

set -e

REFRESH=${1:-3}

# التحقق من وجود nvidia-smi
if ! command -v nvidia-smi &> /dev/null; then
    echo "❌ nvidia-smi غير موجود. تأكد من تثبيت تعريفات NVIDIA."
    exit 1
fi

trap 'echo ""; echo "🛑 تم إيقاف المراقبة."; exit 0' INT

while true; do
    clear
    echo "======================================================"
    echo "🖥️  لوحة مراقبة GPU — $(date '+%H:%M:%S')"
    echo "======================================================"
    
    nvidia-smi --query-gpu=index,name,utilization.gpu,memory.used,memory.total,temperature.gpu,power.draw \
        --format=csv,noheader,nounits | \
    awk -F', ' '{
        printf "🎮 GPU %s | %s\n", $1, $2
        printf "   الاستخدام: %s%% | الذاكرة: %s/%s MB | الحرارة: %s°C | الطاقة: %sW\n\n", $3, $4, $5, $6, $7
    }'
    
    echo "======================================================"
    echo "🐍 عمليات Python الجارية:"
    ps aux | grep -E "python.*train" | grep -v grep | awk '{print "   PID: " $2 " | CPU: " $3 "% | MEM: " $4 "%"}' || echo "   لا توجد عمليات تدريب"
    
    echo ""
    echo "📄 آخر سطر من كل سجل تدريب:"
    for log in logs/*.log; do
        [ -f "$log" ] && echo "   $(basename "$log"): $(tail -n 1 "$log" 2>/dev/null | head -c 80)"
    done
    
    echo ""
    echo "🔄 تحديث كل $REFRESH ثوان | Ctrl+C للخروج"
    sleep "$REFRESH"
done
