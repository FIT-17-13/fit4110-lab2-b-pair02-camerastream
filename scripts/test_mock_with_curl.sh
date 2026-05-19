#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:4010}"
AUTH_HEADER="Authorization: Bearer test-token"

echo "[Lab02] Testing Prism mock server at $BASE_URL"
echo

echo "[1/5] Happy path: GET /health"
curl -i "$BASE_URL/health"
echo "
---"

echo "[2/5] Happy path: GET /vision/results/recent"
curl -i "$BASE_URL/vision/results/recent" -H "$AUTH_HEADER"
echo "
---"

echo "[3/5] Happy path: POST /vision/face-match"
curl -i -X POST "$BASE_URL/vision/face-match" \
  -H "$AUTH_HEADER" \
  -H "Content-Type: application/json" \
  -d '{
    "requestId": "3542ea6f-8cd4-4f16-9a8e-12b72e9f7a99",
    "traceId": "trace-20260519-01",
    "requestedAt": "2026-05-19T08:00:00Z",
    "matchThreshold": 0.80,
    "input": {
      "inputType": "IMAGE_REF",
      "imageRef": "https://storage.campus.local/images/entry-1234.jpg"
    }
  }'
echo "
---"

echo "[4/5] Error case: GET /vision/results/recent without token"
curl -i "$BASE_URL/vision/results/recent"
echo "
---"

echo "[5/5] Happy path: GET /vision/detections/{detectionId}"
curl -i "$BASE_URL/vision/detections/8dd344a4-66c3-4c2b-bc07-a4337f8d2bbb" -H "$AUTH_HEADER"
echo
