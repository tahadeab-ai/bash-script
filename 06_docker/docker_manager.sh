#!/bin/bash
# ============================================================
# docker_manager.sh
# الغرض: بناء وتشغيل حاويات Docker لتدريب الذكاء الاصطناعي
# الاستخدام: ./docker_manager.sh [build|run|shell|clean]
# ============================================================

set -e

IMAGE_NAME=${IMAGE_NAME:-"my_ai_trainer"}
IMAGE_TAG=${IMAGE_TAG:-"latest"}
PROJECT_DIR=$(pwd)

case "$1" in
    build)
        echo "🔨 بناء الصورة: $IMAGE_NAME:$IMAGE_TAG"
        docker build -t "$IMAGE_NAME:$IMAGE_TAG" .
        echo "✅ تم البناء بنجاح."
        docker images | grep "$IMAGE_NAME"
        ;;
    
    run)
        echo "🚀 تشغيل الحاوية مع GPU..."
        docker run --rm --gpus all \
            -v "$PROJECT_DIR/data:/app/data" \
            -v "$PROJECT_DIR/output:/app/output" \
            -v "$PROJECT_DIR/logs:/app/logs" \
            "$IMAGE_NAME:$IMAGE_TAG" \
            python scripts/train.py
        ;;
    
    shell)
        echo "🐚 فتح صدفة داخل الحاوية..."
        docker run --rm -it --gpus all \
            -v "$PROJECT_DIR:/app" \
            "$IMAGE_NAME:$IMAGE_TAG" /bin/bash
        ;;
    
    clean)
        echo "🧹 تنظيف شامل..."
        docker system prune -af
        docker volume prune -f
        echo "✅ تم التنظيف."
        docker system df
        ;;
    
    test-gpu)
        echo "🧪 اختبار GPU داخل Docker..."
        docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi
        ;;
    
    *)
        echo "الاستخدام: $0 {build|run|shell|clean|test-gpu}"
        exit 1
        ;;
esac
