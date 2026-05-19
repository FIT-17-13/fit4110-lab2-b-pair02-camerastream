# Phân tích yêu cầu — vai Provider

- Cặp đàm phán: 01
- Product: AI Vision
- Provider service: AI Vision
- Consumer service: Camera Stream
- Người viết: Pair 01
- Ngày: 2026-05-14

---

## 1. Resource chính

| Resource | Mô tả | Thuộc tính bắt buộc | Thuộc tính tùy chọn |
|---|---|---|---|
| `Detection` | Kết quả nhận dạng từ hình ảnh | `detectionId`, `targetType`, `status`, `createdAt` | `confidence`, `resolvedAt` |
| `Model` | Thông tin model AI đang sử dụng | `modelId`, `version`, `accuracy` | |

---

## 2. Action/API dự kiến

| Method | Path | Mục đích | Consumer gọi khi nào? |
|---|---|---|---|
| GET | `/health` | Kiểm tra service | Hệ thống health check gọi định kỳ |
| POST | `/vision/detect` | Gửi yêu cầu nhận dạng | Khi camera phát hiện motion |
| GET | `/vision/detections/{detectionId}` | Lấy kết quả nhận dạng | Sau khi gửi request và nhận PENDING |
| GET | `/vision/models/info` | Xem thông tin model AI | Khi cần xác nhận phiên bản model |

---

## 3. Error case

Tối thiểu 5 case.

| Status | Tình huống | Response body dự kiến |
|---:|---|---|
| 400 | Payload sai định dạng (thiếu imageUrl) | `Problem` |
| 401 | Thiếu Bearer token | `Problem` |
| 404 | detectionId không tồn tại | `Problem` |
| 422 | cameraId không đúng định dạng (VD: không bắt đầu bằng CAM-) | `Problem` |
| 500 | Lỗi server nội bộ | `Problem` |

---

## 4. Giả định bổ sung

Ghi rõ những điểm user story chưa nói nhưng Provider cần giả định.

- Giả định 1: Consumer sẽ gửi ảnh dưới dạng URL để Provider tải về thay vì gửi raw bytes để tối ưu băng thông.
- Giả định 2: Quá trình phân tích có thể tốn thời gian nên API POST sẽ trả về 202 Accepted và ID để Consumer poll kết quả sau.
- Giả định 3: AI Vision có thể phân biệt Person và Vehicle nên dùng discriminator.

---

## 5. Câu hỏi cho Consumer

1. Tần suất gửi ảnh lên là bao nhiêu frame/s?
2. Có cần webhook callback hay Consumer sẽ chủ động polling GET request?
3. Có cần thêm thông tin bounding box trong kết quả nhận dạng không?

---

## 6. Rủi ro tích hợp

| Rủi ro | Tác động | Đề xuất xử lý |
|---|---|---|
| Tên field không thống nhất | Consumer parse lỗi | Chốt naming trong `openapi.yaml` |
| Quá tải request | Timeout/mock lỗi | Dùng cơ chế async (trả 202) và giới hạn rate limit |
