#!/bin/bash
# ============================================================
# experiment_manager.sh
# الغرض: إدارة تجارب Hyperparameter من ملف CSV
# الاستخدام: ./experiment_manager.sh experiments.csv
# الملف: lr,batch_size,epochs (سطر لكل تجربة)
# ============================================================

set -e

EXPERIMENTS_FILE=${1:-"experiments.csv"}
NUM_GPUS=$(nvidia-smi -L 2>/dev/null | wc -l)
if [ "$NUM_GPUS" -eq 0 ]; then
    NUM_GPUS=1
fi
RESULTS_FILE="results/final_results.csv"

mkdir -p logs results
echo "lr,batch_size,epochs,accuracy,status" > "$RESULTS_FILE"

if [ ! -f "$EXPERIMENTS_FILE" ]; then
    # إنشاء ملف مثال
    cat > "$EXPERIMENTS_FILE" << 'XEOF'
0.001,32,20
0.0005,64,20
0.0001,128,30
0.00005,64,30
XEOF
    echo "📝 تم إنشاء ملف تجارب افتراضي: $EXPERIMENTS_FILE"
fi

run_one() {
    local gpu=$1 lr=$2 bs=$3 ep=$4
    local log="logs/exp_lr${lr}_bs${bs}.log"
    
    echo "🚀 GPU $gpu: lr=$lr bs=$bs epochs=$ep"
    
    if CUDA_VISIBLE_DEVICES=$gpu python scripts/train.py \
        --lr "$lr" --batch_size "$bs" --epochs "$ep" > "$log" 2>&1; then
        
        acc=$(grep "Best Accuracy" "$log" | tail -n 1 | awk '{print $NF}' | tr -d '%')
        [ -z "$acc" ] && acc="N/A"
        echo "$lr,$bs,$ep,$acc,SUCCESS" >> "$RESULTS_FILE"
        echo "✅ GPU $gpu: lr=$lr ✅ دقة=$acc"
    else
        echo "$lr,$bs,$ep,N/A,FAILED" >> "$RESULTS_FILE"
        echo "❌ GPU $gpu: lr=$lr فشل"
    fi
}

gpu_idx=0
pids=()

while IFS=',' read -r lr bs ep; do
    # تخطي السطر الأول إذا كان عنواناً
    [[ "$lr" == "lr" ]] && continue
    
    gpu=$((gpu_idx % NUM_GPUS))
    run_one "$gpu" "$lr" "$bs" "$ep" &
    pids+=($!)
    
    gpu_idx=$((gpu_idx + 1))
    
    if [ $((gpu_idx % NUM_GPUS)) -eq 0 ]; then
        for pid in "${pids[@]}"; do wait "$pid"; done
        pids=()
    fi
done < "$EXPERIMENTS_FILE"

for pid in "${pids[@]}"; do wait "$pid" 2>/dev/null || true; done

echo ""
echo "======================================================"
echo "🏆 أفضل 3 نتائج:"
echo "======================================================"
head -n 1 "$RESULTS_FILE"
tail -n +2 "$RESULTS_FILE" | sort -t',' -k4 -rn | head -n 3
