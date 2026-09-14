#!/bin/bash
# ============================================================
# setup_project.sh
# الغرض: إنشاء هيكل مشروع ذكاء اصطناعي كامل في ثوانٍ
# الاستخدام: ./setup_project.sh my_project_name
# ============================================================

set -e  # أوقف عند أي خطأ

PROJECT_NAME=${1:-"my_ai_project"}
BASE_DIR="$HOME/projects/$PROJECT_NAME"

echo "🚀 إنشاء مشروع جديد: $PROJECT_NAME"
echo "📁 الموقع: $BASE_DIR"

# إنشاء الهيكل الأساسي
mkdir -p "$BASE_DIR"/{data/{raw,processed,external},models,notebooks,scripts,logs,configs,checkpoints,output}

# إنشاء ملفات أساسية
touch "$BASE_DIR/requirements.txt"
touch "$BASE_DIR/README.md"
touch "$BASE_DIR/.gitignore"
touch "$BASE_DIR/configs/config.yaml"
touch "$BASE_DIR/scripts/train.py"
touch "$BASE_DIR/scripts/evaluate.py"
touch "$BASE_DIR/scripts/preprocess.py"

# كتابة .gitignore الاحترافي
cat > "$BASE_DIR/.gitignore" << 'GEOF'
# Data
data/
*.csv
*.zip
*.tar.gz
*.h5
*.pkl

# Models
*.pth
*.pt
*.ckpt
*.safetensors
models/
checkpoints/

# Python
__pycache__/
*.py[cod]
*.egg-info/
.venv/
venv/
.ipynb_checkpoints/

# Logs
logs/
*.log
wandb/
tensorboard/

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
GEOF

# كتابة config.yaml افتراضي
cat > "$BASE_DIR/configs/config.yaml" << 'CEOF'
# إعدادات المشروع
project:
  name: "my_ai_project"
  seed: 42

data:
  train_path: "data/processed/train.csv"
  val_path: "data/processed/val.csv"
  batch_size: 32
  num_workers: 4

model:
  name: "resnet50"
  pretrained: true
  num_classes: 10

training:
  epochs: 50
  learning_rate: 0.001
  optimizer: "adam"
  scheduler: "cosine"

logging:
  log_dir: "logs/"
  save_every: 5
CEOF

cd "$BASE_DIR"

echo "✅ تم إنشاء المشروع بنجاح!"
echo "📂 الهيكل:"
tree -L 2 "$BASE_DIR" 2>/dev/null || ls -R "$BASE_DIR"

echo ""
echo "👉 للبدء:"
echo "   cd $BASE_DIR"
echo "   git init"
echo "   code ."
