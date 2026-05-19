# Phân tích yêu cầu — vai Consumer

- Cặp đàm phán: Core Business (Consumer) ↔ AI Vision (Provider)
- Product: Smart Campus Access và Security
- Consumer service: core-business-service
- Provider service: ai-vision-service
- Người viết: Nhóm pair-02
- Ngày: 2026-05-19

---

## 1. Resource Consumer cần nhận/gửi

| Resource | Consumer dùng để làm gì? | Field bắt buộc với Consumer | Field có thể tùy chọn |
|---|---|---|---|
| FaceMatchRequest | Gửi yêu cầu so khớp khuôn mặt | requestId, traceId, requestedAt, input | matchThreshold |
| FaceMatchResponse | Nhận kết quả phân tích face-match | requestId, detectionId, matchStatus, confidence, modelVersion, processedAt, traceId | matchedPersonId, detail |
| DetectionResult | Kiểm tra lại kết quả theo id | requestId, detectionId, matchStatus, confidence, modelVersion, processedAt, traceId | reviewedBy |
| DetectionPage | Hiển thị kết quả gần nhất | items, nextCursor, hasMore | |

---

## 2. API Consumer cần gọi

| Method | Path | Lúc nào gọi? | Kỳ vọng response |
|---|---|---|---|
| GET | `/health` | Trước khi gọi API quan trọng | 200 OK với service status |
| POST | `/vision/face-match` | Khi cần xác thực ảnh hoặc truy vấn face match | 200 OK với match result |
| GET | `/vision/detections/{detectionId}` | Khi cần kiểm tra chi tiết kết quả cũ | 200 OK với chi tiết detection |
| GET | `/vision/results/recent` | Khi cần audit log hoặc dashboard | 200 OK với danh sách gần nhất |

---

## 3. Error case Consumer cần xử lý

Tối thiểu 5 case.

| Status | Consumer hiểu là gì? | Consumer sẽ xử lý thế nào? |
|---:|---|---|
| 400 | Request hoặc schema sai | Kiểm tra payload, log detail và fix request |
| 401 | Thiếu token hoặc token không hợp lệ | Kiểm tra cấu hình auth và yêu cầu token mới |
| 403 | Không đủ quyền truy cập | Báo lỗi quyền, ngừng gọi API này |
| 404 | detectionId không tồn tại | Hiển thị không tìm thấy hoặc yêu cầu lại dữ liệu khác |
| 409 | Trùng requestId/xung đột nghiệp vụ | Tạm dừng, không retry cùng requestId |
| 422 | Dữ liệu nghiệp vụ không chấp nhận được | Hiển thị lý do lỗi từ field và sửa payload |

---

## 4. Giả định bổ sung

- ID detection được tạo bởi Provider và có dạng UUID.
- Consumer có thể gửi ảnh bằng `imageRef` hoặc embedding vector.
- Khi không có match rõ ràng, Provider trả `LOW_CONFIDENCE` thay vì lỗi 422.

---

## 5. Câu hỏi cho Provider

1. Nếu gửi `imageRef`, có cần kèm thông tin kích thước/mime type?
2. Giới hạn chiều dài `embeddingVector` là bao nhiêu?
3. Có cần `reviewedBy` khi detection chưa được xét duyệt?

---

## 6. Rủi ro tích hợp

| Rủi ro | Tác động | Đề xuất xử lý |
|---|---|---|
| Provider đổi định dạng input | Consumer parse lỗi | Chốt `FaceMatchInput` với discriminator rõ ràng |
| Consumer gửi traceId sai | Khó debug | Bắt buộc `traceId` và log rõ source |
| Response lỗi không chuẩn | Không xử lý được lỗi | Chốt `application/problem+json` và schema Problem |
| Phiên bản model khác nhau | Confidence khác | Consumer chỉ dùng `modelVersion` để audit |
| Pagination không nhất quán | Hiển thị kết quả sai | Chốt `cursor` + `limit` cho `/vision/results/recent` |
