#!/bin/bash
# ============================================================
# api_test.sh
# الغرض: اختبار APIs (OpenAI, HuggingFace, خادم محلي)
# الاستخدام: ./api_test.sh [openai|huggingface|local|health|download]
# ============================================================

set -e

# حمّل المتغيرات من .env إن وجد
[ -f .env ] && export $(grep -v '^#' .env | xargs)

case "$1" in
    openai)
        echo "🤖 اختبار OpenAI API..."
        if [ -z "$OPENAI_API_KEY" ]; then
            echo "❌ OPENAI_API_KEY غير محدد في .env"
            exit 1
        fi
        
        curl -s https://api.openai.com/v1/chat/completions \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $OPENAI_API_KEY" \
            -d '{
                "model": "gpt-3.5-turbo",
                "messages": [{"role": "user", "content": "قل مرحبا بالعربية فقط"}],
                "max_tokens": 50
            }' | python -m json.tool 2>/dev/null || echo "❌ فشل الاتصال."
        ;;
    
    huggingface)
        echo "🤗 اختبار HuggingFace API..."
        if [ -z "$HF_TOKEN" ]; then
            echo "⚠️ HF_TOKEN غير محدد. سيتم الاختبار بدون مصادقة."
        fi
        
        curl -s https://huggingface.co/api/models/bert-base-uncased \
            -H "Authorization: Bearer $HF_TOKEN" | \
            python -c "import sys,json; d=json.load(sys.stdin); print(f'✅ النموذج: {d.get(\"modelId\", \"bert-base-uncased\")}'); print(f'   التنزيلات: {d.get(\"downloads\",\"N/A\")}')"
        ;;
    
    local)
        LOCAL_URL=${2:-"http://localhost:8000"}
        echo "🏠 اختبار خادم محلي: $LOCAL_URL"
        curl -s --max-time 5 "$LOCAL_URL/health" || echo "❌ لا يوجد رد."
        ;;
    
    health)
        echo "🏥 فحص صحة عدة خدمات..."
        for url in "https://api.github.com" "https://pypi.org" "https://huggingface.co"; do
            if curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$url" | grep -q "200"; then
                echo "   ✅ $url"
            else
                echo "   ❌ $url"
            fi
        done
        ;;
    
    download)
        URL=$2
        OUTPUT=${3:-"downloaded_file"}
        echo "📥 تحميل: $URL"
        curl -L -o "$OUTPUT" --progress-bar "$URL"
        echo "✅ تم: $OUTPUT"
        ;;
    
    *)
        echo "الاستخدام: $0 {openai|huggingface|local|health|download} [args]"
        exit 1
        ;;
esac
