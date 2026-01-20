#!/bin/bash

# Configuration
AGENT_URL="http://localhost:8000/prompt"
OUTPUT_FILE="benchmark_results_$(date +%Y%m%d_%H%M%S).txt"

# Benchmarking Prompts
# You can add or modify these prompts to test different geo-capabilities
PROMPTS=(
    "この日本の住所の緯度経度座標を教えてください: 東京都墨田区押上１丁目１−２"
    "次の座標について、住所を「都道府県・市区町村レベル」に要約してください: 35.7107543838,139.6200434882"
    "三鷹駅から吉祥寺駅までの車での距離はどれくらいですか？"    
    "池袋駅周辺500mで、「カフェ」と「コンビニ」のどちらが多いかを推定してください。カウント結果と結論を返してください。"
    "横浜駅周辺の500mメッシュ（半径1km以内）を対象に、高齢者人口が多いメッシュほど「病院/クリニック」が多い傾向があるかを推定してください。可能なら簡単な集計結果も出してください。"
)

TOTAL_PROMPTS=${#PROMPTS[@]}

echo "--- LLM Benchmark Started at $(date) ---" | tee -a "$OUTPUT_FILE"
echo "Target URL: $AGENT_URL" | tee -a "$OUTPUT_FILE"
echo "------------------------------------------------" | tee -a "$OUTPUT_FILE"

# Loop through prompts
for i in "${!PROMPTS[@]}"; do
    PROMPT="${PROMPTS[$i]}"
    echo "[$(($i+1))/$TOTAL_PROMPTS] Testing Prompt: $PROMPT" | tee -a "$OUTPUT_FILE"

    # Use curl with -w to measure 'time_total'
    # --no-buffer ensures we don't wait for a full buffer to see results
    # -s for silent mode (hides progress bar)
    START_TIME=$(date +%s.%N)
    
    RESPONSE=$(curl -s -X POST "$AGENT_URL" \
        -H "Content-Type: application/json" \
        -d "{\"prompt\": \"$PROMPT\"}")
    
    END_TIME=$(date +%s.%N)
    
    # Calculate duration (works on macOS and Linux)
    DURATION=$(echo "$END_TIME - $START_TIME" | bc)

    # Save to Output File
    echo "Response: $RESPONSE" >> "$OUTPUT_FILE"
    echo "Time Taken: ${DURATION}s" | tee -a "$OUTPUT_FILE"
    echo "------------------------------------------------" >> "$OUTPUT_FILE"
    
    # Optional: Brief pause to let the system cool down/reset memory
    sleep 2
done

echo "Benchmark Complete. Results saved to: $OUTPUT_FILE"

