# Curl samples for AI Vision mock API

Replace `YOUR_TOKEN` with a valid bearer token for authentication.

1. Check service health

```bash
curl -i http://localhost:4010/health
```

2. Submit face-match using image reference

```bash
curl -i -X POST http://localhost:4010/vision/face-match \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "requestId":"3542ea6f-8cd4-4f16-9a8e-12b72e9f7a99",
    "traceId":"trace-20260519-01",
    "requestedAt":"2026-05-19T08:00:00Z",
    "matchThreshold":0.80,
    "input":{
      "inputType":"IMAGE_REF",
      "imageRef":"https://storage.campus.local/images/entry-1234.jpg"
    }
  }'
```

3. Submit face-match using embedding vector

```bash
curl -i -X POST http://localhost:4010/vision/face-match \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "requestId":"5c7a1d2e-f0b4-4817-b0ad-8f22386d5204",
    "traceId":"trace-20260519-02",
    "requestedAt":"2026-05-19T08:01:00Z",
    "matchThreshold":0.75,
    "input":{
      "inputType":"FACE_EMBEDDING",
      "embeddingVector":[0.12,-0.04,0.88,0.66,0.34]
    }
  }'
```

4. Get detection result by ID

```bash
curl -i -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:4010/vision/detections/8dd344a4-66c3-4c2b-bc07-a4337f8d2bbb
```

5. List recent detection results

```bash
curl -i -H "Authorization: Bearer YOUR_TOKEN" \
  "http://localhost:4010/vision/results/recent?limit=5"
```
```
