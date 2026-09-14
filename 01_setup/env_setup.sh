#!/bin/bash
# ============================================================
# env_setup.sh
# الغرض: إعداد بيئة Conda/Python كاملة لمشروع ذكاء اصطناعي
# الاستخدام: ./env_setup.sh [project_name] [python_version]
# ============================================================

set -e

PROJECT_NAME=${1:-"ai_env"}
PYTHON_VERSION=${2:-"3.10"}

echo "🐍 إنشاء بيئة Conda: $PROJECT_NAME (Python $PYTHON_VERSION)"

# التحقق من وجود Conda
if ! command -v conda &> /dev/null; then
    echo "❌ Conda غير مثبت. حمّله من: https://docs.conda.io/miniconda.html"
    exit 1
fi

# إنشاء البيئة
conda create -y -n "$PROJECT_NAME" python="$PYTHON_VERSION"

# تفعيل البيئة
eval "$(conda shell.bash hook)"
conda activate "$PROJECT_NAME"

echo "📦 تثبيت المكتبات الأساسية..."

# تحديث pip
pip install --upgrade pip

# تثبيت المكتبات الأساسية
pip install \
    numpy pandas matplotlib seaborn \
    scikit-learn scipy \
    jupyter jupyterlab ipykernel \
    tqdm pyyaml python-dotenv \
    pytest black flake8

# تثبيت PyTorch (عدّل حسب CUDA)
echo "🔥 هل تريد تثبيت PyTorch مع CUDA؟ (y/n)"
read -r install_torch
if [ "$install_torch" = "y" ]; then
    read -r -p "أدخل إصدار CUDA (مثال: cu121): " cuda_version
    pip install torch torchvision torchaudio --index-url "https://download.pytorch.org/whl/$cuda_version"
fi

echo "🤗 تثبيت مكتبات Hugging Face..."
pip install transformers datasets accelerate evaluate

echo "📊 تثبيت أدوات التجارب..."
pip install wandb tensorboard

# تسجيل البيئة كـ kernel في Jupyter
python -m ipykernel install --user --name="$PROJECT_NAME" --display-name="Python ($PROJECT_NAME)"

echo "✅ تم إعداد البيئة بنجاح!"
echo "👉 للتفعيل: conda activate $PROJECT_NAME"

# حفظ قائمة المكتبات
pip freeze > requirements_lock.txt
echo "📄 تم حفظ المتطلبات في requirements_lock.txt"
