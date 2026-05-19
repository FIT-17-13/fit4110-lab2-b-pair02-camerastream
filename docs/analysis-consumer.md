# Phân tích yêu cầu — vai Consumer

- Cặp đàm phán: 01
- Product: Camera Stream
- Provider service: AI Vision
- Consumer service: Camera Stream
- Người viết: Pair 01
- Ngày: 2026-05-14

---

## 1. Mục tiêu tích hợp

- Nhu cầu chính: Gửi frame hình ảnh lên AI Vision để nhận diện đối tượng (người, xe).
- Dữ liệu đầu vào sẽ cung cấp cho Provider: `cameraId`, `imageUrl`, `timestamp`.
- Dữ liệu mong muốn nhận lại từ Provider: `targetType`, `confidence`, `licensePlate` (nếu là xe).

---

## 2. API dự kiến cần gọi

| Method | Path | Tần suất dự kiến | Timeout chịu đựng |
|---|---|---|---|
| POST | `/vision/detect` | Khi có motion (1-2 req/s/camera) | 5 giây |
| GET | `/vision/detections/{detectionId}` | 1 req/s sau khi nhận 202 | 2 giây |

---

## 3. Câu hỏi cho Provider

1. Mức độ chính xác (confidence) tối thiểu AI trả về là bao nhiêu?
2. URL ảnh truyền lên có cần xác thực (token) để AI Vision tải xuống không?
3. Nếu ảnh bị mờ hoặc không nhận diện được, Provider trả về gì?
