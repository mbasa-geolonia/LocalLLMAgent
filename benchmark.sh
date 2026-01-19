#!/bin/bash

# 1. Configuration
AGENT_URL="http://localhost:8000/prompt"
OUTPUT_FILE="benchmark_results_$(date +%Y%m%d_%H%M%S).txt"

# 2. Benchmarking Prompts
# You can add or modify these 5 prompts to test different geo-capabilities
PROMPTS=(
    "Find the coordinates for the Space Needle in Seattle."
    "Calculate the shortest driving path from the Eiffel Tower to the Louvre Museum."
    "Create a 15-minute drive time polygon around the Empire State Building."
    "What is the geocoded address for coordinates 40.748817, -73.985428?"
    "Is the path from London to Manchester shorter via Birmingham or the M1?"
)

echo "--- LLM Benchmark Started at $(date) ---" | tee -a "$OUTPUT_FILE"
echo "Target URL: $AGENT_URL" | tee -a "$OUTPUT_FILE"
echo "------------------------------------------------" | tee -a "$OUTPUT_FILE"

# 3. Loop through prompts
for i in "${!PROMPTS[@]}"; do
    PROMPT="${PROMPTS[$i]}"
    echo "[$(($i+1))/5] Testing Prompt: $PROMPT" | tee -a "$OUTPUT_FILE"

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

    # 4. Save to Output File
    echo "Response: $RESPONSE" >> "$OUTPUT_FILE"
    echo "Time Taken: ${DURATION}s" | tee -a "$OUTPUT_FILE"
    echo "------------------------------------------------" >> "$OUTPUT_FILE"
    
    # Optional: Brief pause to let the RPi5 cool down/reset memory
    sleep 2
done

echo "Benchmark Complete. Results saved to: $OUTPUT_FILE"

