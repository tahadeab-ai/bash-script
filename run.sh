#!/bin/bash
# ============================================================
# run.sh — الواجهة الرئيسية لمكتبة أدوات الذكاء الاصطناعي
# الاستخدام: ./run.sh [command] [args]
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_help() {
    cat << 'HELP_EOF'
╔══════════════════════════════════════════════════════════╗
║  🤖 AI Bash Toolbox — مكتبة أدوات هندسة الذكاء الاصطناعي  ║
╚══════════════════════════════════════════════════════════╝

الاستخدام: ./run.sh [command] [args]

📁 الأوامر المتاحة:

  🔧 الإعداد:
    setup <name>           إنشاء مشروع جديد
    env <name> [py_ver]    إنشاء بيئة Conda

  📊 البيانات:
    download <name> <url>  تحميل مجموعة بيانات
    inspect <file>         فحص ملف بيانات

  🚀 التدريب:
    train-parallel         تدريب متوازي على عدة GPUs
    experiments <file.csv> إدارة تجارب من ملف
    resilient [retries]    تدريب صامد ضد الأعطال

  📡 المراقبة:
    monitor [sec]          لوحة مراقبة GPU
    health                 فحص صحة النظام

  🧹 الصيانة:
    backup [dest]          نسخ احتياطي
    cleanup [n] [mode]     تنظيف نقاط التفتيش

  🐳 Docker:
    docker <action>        build|run|shell|clean|test-gpu

  🔌 APIs:
    api <action>           openai|huggingface|local|health|download

  📄 السجلات:
    analyze <log_file>     تحليل سجل تدريب

مثال:
  ./run.sh setup my_project
  ./run.sh monitor 5
  ./run.sh api openai
HELP_EOF
}

COMMAND=$1
shift || true

case "$COMMAND" in
    setup)          bash "$SCRIPT_DIR/01_setup/setup_project.sh" "$@" ;;
    env)            bash "$SCRIPT_DIR/01_setup/env_setup.sh" "$@" ;;
    download)       bash "$SCRIPT_DIR/02_data/download_data.sh" "$@" ;;
    inspect)        bash "$SCRIPT_DIR/02_data/inspect_data.sh" "$@" ;;
    train-parallel) bash "$SCRIPT_DIR/03_training/train_parallel.sh" "$@" ;;
    experiments)    bash "$SCRIPT_DIR/03_training/experiment_manager.sh" "$@" ;;
    resilient)      bash "$SCRIPT_DIR/03_training/resilient_trainer.sh" "$@" ;;
    monitor)        bash "$SCRIPT_DIR/04_monitoring/monitor_gpu.sh" "$@" ;;
    health)         bash "$SCRIPT_DIR/04_monitoring/system_health.sh" "$@" ;;
    backup)         bash "$SCRIPT_DIR/05_maintenance/backup_results.sh" "$@" ;;
    cleanup)        bash "$SCRIPT_DIR/05_maintenance/cleanup_checkpoints.sh" "$@" ;;
    docker)         bash "$SCRIPT_DIR/06_docker/docker_manager.sh" "$@" ;;
    api)            bash "$SCRIPT_DIR/07_utils/api_test.sh" "$@" ;;
    analyze)        bash "$SCRIPT_DIR/07_utils/log_analyzer.sh" "$@" ;;
    *)              show_help ;;
esac
