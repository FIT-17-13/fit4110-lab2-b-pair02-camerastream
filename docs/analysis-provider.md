# Phân tích yêu cầu — vai Provider

- Cặp đàm phán: Core Business (Consumer) ↔ AI Vision (Provider)
- Product: Smart Campus Access và Security
- Provider service: ai-vision-service
- Consumer service: core-business-service
- Người viết: Nhóm pair-02
- Ngày: 2026-05-19

---

## 1. Resource chính

| Resource | Mô tả | Thuộc tính bắt buộc | Thuộc tính tùy chọn |
|---|---|---|---|
| FaceMatchRequest | Yêu cầu phân tích face-match từ Core Business | requestId, traceId, requestedAt, input | matchThreshold |
| FaceMatchResponse | Kết quả face-match trả về Consumer | requestId, detectionId, matchStatus, confidence, modelVersion, processedAt, traceId | matchedPersonId, detail |
| DetectionResult | Chi tiết detection đã xử lý | tất cả thuộc tính FaceMatchResponse | reviewedBy |
| DetectionPage | Trang kết quả gần nhất | items, nextCursor, hasMore | |

---

## 2. Action/API dự kiến

| Method | Path | Mục đích | Consumer gọi khi nào? |
|---|---|---|---|
| GET | `/health` | Kiểm tra service AI Vision đang sống | Khi consumer cần xác nhận service sẵn sàng |
| POST | `/vision/face-match` | Gửi yêu cầu phân tích ảnh hoặc embedding | Khi cần xác thực danh tính hoặc so khớp khuôn mặt |
| GET | `/vision/detections/{detectionId}` | Lấy chi tiết kết quả đã ghi nhận | Khi cần xem lại kết quả trước đó |
| GET | `/vision/results/recent` | Lấy danh sách kết quả gần nhất | Khi cần bảng điều khiển hoặc audit gần đây |

---

## 3. Error case

Tối thiểu 5 case.

| Status | Tình huống | Response body dự kiến |
|---:|---|---|
| 400 | Payload sai định dạng hoặc JSON không hợp lệ | `Problem` |
| 401 | Thiếu Bearer token hoặc token không hợp lệ | `Problem` |
| 403 | Token hợp lệ nhưng không có quyền truy cập | `Problem` |
| 404 | detectionId không tồn tại | `Problem` |
| 409 | Trùng requestId hoặc xung đột nghiệp vụ | `Problem` |
| 422 | Payload hợp lệ JSON nhưng vi phạm nghiệp vụ | `Problem` |

---

## 4. Giả định bổ sung

- Consumer luôn kèm `traceId` để audit và đối chiếu log.
- Consumer có thể gửi `imageRef` hoặc `embeddingVector` tùy theo nguồn dữ liệu.
- Nếu confidence thấp, AI Vision trả `LOW_CONFIDENCE` thay vì lỗi 422 để giữ synchronous flow.

---

## 5. Câu hỏi cho Consumer

1. Consumer cần gửi ảnh trực tiếp hay chỉ dùng `imageRef` URL?
2. Ngưỡng `matchThreshold` mặc định là bao nhiêu và có thể override không?
3. Khi không tìm thấy match, Consumer mong muốn trả về `NO_MATCH` hay `LOW_CONFIDENCE`?

---

## 6. Rủi ro tích hợp

| Rủi ro | Tác động | Đề xuất xử lý |
|---|---|---|
| InputType không đồng nhất | Sai parser oneOf | Chốt discriminator `inputType` và mapping rõ ràng |
| TraceId thiếu hoặc không nhất quán | Khó điều tra lỗi | Bắt buộc `traceId` trong FaceMatchRequest |
| Kiểu dữ liệu null | Sai use case khi parsing | Dùng union types thay vì `nullable` |
| Truy vấn pagination khác nhau | Lấy dữ liệu không chính xác | Thống nhất `cursor` + `limit` trong /vision/results/recent |
| Response lỗi không chuẩn | Consumer không xử lý được | Chuẩn hóa error theo Problem Details |
