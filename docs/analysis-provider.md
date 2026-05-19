# Phân tích yêu cầu — vai Provider

<<<<<<< HEAD
- Cặp đàm phán: 01
- Product: AI Vision
- Provider service: AI Vision
- Consumer service: Camera Stream
- Người viết: Pair 01
- Ngày: 2026-05-14
=======
- Cặp đàm phán: Core Business (Consumer) ↔ AI Vision (Provider)
- Product: Smart Campus Access và Security
- Provider service: ai-vision-service
- Consumer service: core-business-service
- Người viết: Nhóm pair-02
- Ngày: 2026-05-19
>>>>>>> 45f52f59e2299856b27574d089c9f6fbc91febd6

---

## 1. Resource chính

| Resource | Mô tả | Thuộc tính bắt buộc | Thuộc tính tùy chọn |
|---|---|---|---|
<<<<<<< HEAD
| `Detection` | Kết quả nhận dạng từ hình ảnh | `detectionId`, `targetType`, `status`, `createdAt` | `confidence`, `resolvedAt` |
| `Model` | Thông tin model AI đang sử dụng | `modelId`, `version`, `accuracy` | |
=======
| FaceMatchRequest | Yêu cầu phân tích face-match từ Core Business | requestId, traceId, requestedAt, input | matchThreshold |
| FaceMatchResponse | Kết quả face-match trả về Consumer | requestId, detectionId, matchStatus, confidence, modelVersion, processedAt, traceId | matchedPersonId, detail |
| DetectionResult | Chi tiết detection đã xử lý | tất cả thuộc tính FaceMatchResponse | reviewedBy |
| DetectionPage | Trang kết quả gần nhất | items, nextCursor, hasMore | |
>>>>>>> 45f52f59e2299856b27574d089c9f6fbc91febd6

---

## 2. Action/API dự kiến

| Method | Path | Mục đích | Consumer gọi khi nào? |
|---|---|---|---|
<<<<<<< HEAD
| GET | `/health` | Kiểm tra service | Hệ thống health check gọi định kỳ |
| POST | `/vision/detect` | Gửi yêu cầu nhận dạng | Khi camera phát hiện motion |
| GET | `/vision/detections/{detectionId}` | Lấy kết quả nhận dạng | Sau khi gửi request và nhận PENDING |
| GET | `/vision/models/info` | Xem thông tin model AI | Khi cần xác nhận phiên bản model |
=======
| GET | `/health` | Kiểm tra service AI Vision đang sống | Khi consumer cần xác nhận service sẵn sàng |
| POST | `/vision/face-match` | Gửi yêu cầu phân tích ảnh hoặc embedding | Khi cần xác thực danh tính hoặc so khớp khuôn mặt |
| GET | `/vision/detections/{detectionId}` | Lấy chi tiết kết quả đã ghi nhận | Khi cần xem lại kết quả trước đó |
| GET | `/vision/results/recent` | Lấy danh sách kết quả gần nhất | Khi cần bảng điều khiển hoặc audit gần đây |
>>>>>>> 45f52f59e2299856b27574d089c9f6fbc91febd6

---

## 3. Error case

Tối thiểu 5 case.

| Status | Tình huống | Response body dự kiến |
|---:|---|---|
<<<<<<< HEAD
| 400 | Payload sai định dạng (thiếu imageUrl) | `Problem` |
| 401 | Thiếu Bearer token | `Problem` |
| 404 | detectionId không tồn tại | `Problem` |
| 422 | cameraId không đúng định dạng (VD: không bắt đầu bằng CAM-) | `Problem` |
| 500 | Lỗi server nội bộ | `Problem` |
=======
| 400 | Payload sai định dạng hoặc JSON không hợp lệ | `Problem` |
| 401 | Thiếu Bearer token hoặc token không hợp lệ | `Problem` |
| 403 | Token hợp lệ nhưng không có quyền truy cập | `Problem` |
| 404 | detectionId không tồn tại | `Problem` |
| 409 | Trùng requestId hoặc xung đột nghiệp vụ | `Problem` |
| 422 | Payload hợp lệ JSON nhưng vi phạm nghiệp vụ | `Problem` |
>>>>>>> 45f52f59e2299856b27574d089c9f6fbc91febd6

---

## 4. Giả định bổ sung

<<<<<<< HEAD
Ghi rõ những điểm user story chưa nói nhưng Provider cần giả định.

- Giả định 1: Consumer sẽ gửi ảnh dưới dạng URL để Provider tải về thay vì gửi raw bytes để tối ưu băng thông.
- Giả định 2: Quá trình phân tích có thể tốn thời gian nên API POST sẽ trả về 202 Accepted và ID để Consumer poll kết quả sau.
- Giả định 3: AI Vision có thể phân biệt Person và Vehicle nên dùng discriminator.
=======
- Consumer luôn kèm `traceId` để audit và đối chiếu log.
- Consumer có thể gửi `imageRef` hoặc `embeddingVector` tùy theo nguồn dữ liệu.
- Nếu confidence thấp, AI Vision trả `LOW_CONFIDENCE` thay vì lỗi 422 để giữ synchronous flow.
>>>>>>> 45f52f59e2299856b27574d089c9f6fbc91febd6

---

## 5. Câu hỏi cho Consumer

<<<<<<< HEAD
1. Tần suất gửi ảnh lên là bao nhiêu frame/s?
2. Có cần webhook callback hay Consumer sẽ chủ động polling GET request?
3. Có cần thêm thông tin bounding box trong kết quả nhận dạng không?
=======
1. Consumer cần gửi ảnh trực tiếp hay chỉ dùng `imageRef` URL?
2. Ngưỡng `matchThreshold` mặc định là bao nhiêu và có thể override không?
3. Khi không tìm thấy match, Consumer mong muốn trả về `NO_MATCH` hay `LOW_CONFIDENCE`?
>>>>>>> 45f52f59e2299856b27574d089c9f6fbc91febd6

---

## 6. Rủi ro tích hợp

| Rủi ro | Tác động | Đề xuất xử lý |
|---|---|---|
<<<<<<< HEAD
| Tên field không thống nhất | Consumer parse lỗi | Chốt naming trong `openapi.yaml` |
| Quá tải request | Timeout/mock lỗi | Dùng cơ chế async (trả 202) và giới hạn rate limit |
=======
| InputType không đồng nhất | Sai parser oneOf | Chốt discriminator `inputType` và mapping rõ ràng |
| TraceId thiếu hoặc không nhất quán | Khó điều tra lỗi | Bắt buộc `traceId` trong FaceMatchRequest |
| Kiểu dữ liệu null | Sai use case khi parsing | Dùng union types thay vì `nullable` |
| Truy vấn pagination khác nhau | Lấy dữ liệu không chính xác | Thống nhất `cursor` + `limit` trong /vision/results/recent |
| Response lỗi không chuẩn | Consumer không xử lý được | Chuẩn hóa error theo Problem Details |
>>>>>>> 45f52f59e2299856b27574d089c9f6fbc91febd6
