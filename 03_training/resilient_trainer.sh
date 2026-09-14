#!/bin/bash
# ============================================================
# resilient_trainer.sh
# الغرض: تشغيل التدريب مع إعادة المحاولة التلقائية عند الفشل
# الاستخدام: ./resilient_trainer.sh [max_retries]
# ============================================================

set -e

MAX_RETRIES=${1:-3}
RETRY=0
TRAIN_CMD="python scripts/train.py --epochs 100 --batch_size 32"

mkdir -p logs

while [ $RETRY -lt $MAX_RETRIES ]; do
    echo "======================================================"
    echo "🔄 المحاولة $((RETRY + 1)) من $MAX_RETRIES"
    echo "⏰ الوقت: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "======================================================"
    
    START_TIME=$(date +%s)
    
    if $TRAIN_CMD 2>&1 | tee "logs/training_attempt_$((RETRY+1)).log"; then
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))
        echo ""
        echo "✅ نجح التدريب في $((DURATION / 60)) دقيقة و $((DURATION % 60)) ثانية."
        exit 0
    fi
    
    RETRY=$((RETRY + 1))
    if [ $RETRY -lt $MAX_RETRIES ]; then
        echo ""
        echo "❌ فشل التدريب. إعادة المحاولة بعد 30 ثانية..."
        sleep 30
    fi
done

echo ""
echo "💀 فشل التدريب بعد $MAX_RETRIES محاولات."
echo "📄 راجع السجلات في logs/"
exit 1
