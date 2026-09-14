#!/bin/bash
# ============================================================
# train_parallel.sh
# الغرض: تشغيل تجارب متعددة بالتوازي على كروت شاشة مختلفة
# الاستخدام: ./train_parallel.sh
# ============================================================

set -e

# عدد الكروت المتاحة
NUM_GPUS=$(nvidia-smi -L 2>/dev/null | wc -l)
if [ "$NUM_GPUS" -eq 0 ]; then
    NUM_GPUS=1
fi
echo "🖥️ عدد الكروت المتاحة: $NUM_GPUS"

# قائمة معدلات التعلم للتجربة
LEARNING_RATES=(0.001 0.0005 0.0001 0.00005)
EPOCHS=50

# إنشاء مجلد للسجلات
mkdir -p logs

# دالة تشغيل تجربة واحدة
run_experiment() {
    local gpu_id=$1
    local lr=$2
    local log_file="logs/exp_lr${lr}_gpu${gpu_id}.log"
    
    echo "🚀 GPU $gpu_id: بدء التدريب بـ lr=$lr"
    CUDA_VISIBLE_DEVICES=$gpu_id python scripts/train.py \
        --learning_rate "$lr" \
        --epochs "$EPOCHS" > "$log_file" 2>&1
    
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo "✅ GPU $gpu_id: انتهى التدريب (lr=$lr)"
    else
        echo "❌ GPU $gpu_id: فشل التدريب (lr=$lr) - رمز $exit_code"
    fi
}

# تشغيل التجارب بالتوازي
idx=0
pids=()

for lr in "${LEARNING_RATES[@]}"; do
    gpu_id=$((idx % NUM_GPUS))
    
    run_experiment "$gpu_id" "$lr" &
    pids+=($!)
    
    idx=$((idx + 1))
    
    # إذا وصلنا لحد الكروت، انتظر حتى تنتهي الموجة الحالية
    if [ $((idx % NUM_GPUS)) -eq 0 ]; then
        echo "⏳ انتظار انتهاء الموجة الحالية..."
        for pid in "${pids[@]}"; do
            wait "$pid"
        done
        pids=()
    fi
done

# انتظر أي عمليات متبقية
for pid in "${pids[@]}"; do
    wait "$pid" 2>/dev/null || true
done

echo ""
echo "🎉 انتهت جميع التجارب!"
echo "📊 استخراج النتائج..."

grep -H "Best Accuracy" logs/exp_lr*.log 2>/dev/null || echo "لا توجد نتائج بعد"
