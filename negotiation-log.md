<<<<<<< HEAD
# Biên bản đàm phán (Negotiation Log)

Cặp đàm phán: 01 (Camera Stream ↔ AI Vision)
Ngày: 2026-05-14

## Sign-off
- Đại diện Provider: **Pair 01 — Provider (AI Vision Service)** (Đã ký)
- Đại diện Consumer: **Pair 01 — Consumer (Camera Stream Service)** (Đã ký)
- Chứng kiến (Witness): **Giảng viên hướng dẫn / AI Tutor** (Đã ký)

---

### Issue 01: Định dạng dữ liệu truyền tải hình ảnh
- **Bối cảnh**: Camera có thể truyền ảnh base64 hoặc URL.
- **Vấn đề**: Ảnh base64 sẽ làm phình payload rất lớn.
- **Đề xuất**: Dùng JSON với trường `imageUrl`. Camera tự lưu ảnh vào object storage và truyền URL.
- **Quyết định**: Chấp nhận dùng `imageUrl`.
- **Rationale**: Tối ưu băng thông mạng, giảm nguy cơ timeout.
- **Tác động**: Consumer phải xây dựng cơ chế upload ảnh lên storage trước khi gọi API.

### Issue 02: Cơ chế nhận kết quả (Sync vs Async/Polling)
- **Bối cảnh**: Phân tích ảnh có thể tốn từ 500ms đến 2s.
- **Vấn đề**: Giữ kết nối HTTP mở quá lâu dễ bị timeout và tốn resource.
- **Đề xuất**: API `/vision/detect` trả về `202 Accepted` kèm `detectionId`. Consumer gọi `/vision/detections/{detectionId}` để lấy kết quả.
- **Quyết định**: Đồng ý dùng mô hình polling.
- **Rationale**: Đảm bảo hệ thống chịu tải tốt hơn khi có nhiều camera gửi ảnh cùng lúc.
- **Tác động**: Thay đổi flow phía Consumer, cần thêm logic retry/polling.

### Issue 03: Phân loại đối tượng nhận diện
- **Bối cảnh**: AI có thể nhận diện nhiều loại đối tượng khác nhau.
- **Vấn đề**: Các đối tượng khác nhau sẽ có thuộc tính khác nhau (Người có khẩu trang, Xe có biển số).
- **Đề xuất**: Dùng Polymorphism (`oneOf` + `discriminator`) trên trường `targetType` với 2 giá trị `PERSON` và `VEHICLE`.
- **Quyết định**: Chấp nhận.
- **Rationale**: Định nghĩa rõ ràng cấu trúc dữ liệu cho từng loại đối tượng, giúp Consumer parse dễ dàng hơn.
- **Tác động**: OpenAPI schema phức tạp hơn, cần dùng `$ref`.

### Issue 04: Xử lý trường hợp không nhận diện được
- **Bối cảnh**: Có thể ảnh gửi lên bị mờ hoặc không có người/xe.
- **Vấn đề**: Cần trả về trạng thái rõ ràng thay vì bỏ qua.
- **Đề xuất**: Thêm status `FAILED` cho `DetectionResult`.
- **Quyết định**: Chấp nhận.
- **Rationale**: Consumer biết chính xác tiến trình đã xử lý xong nhưng không ra kết quả.
- **Tác động**: Provider phải cập nhật status FAILED khi confidence quá thấp.

### Issue 05: Định dạng mã Camera ID
- **Bối cảnh**: Provider cần biết nguồn gửi ảnh.
- **Vấn đề**: ID camera lộn xộn có thể gây khó khăn cho việc quản lý.
- **Đề xuất**: Ép chuẩn regex `^CAM-[A-Z0-9-]+$` cho `cameraId`.
- **Quyết định**: Đồng ý.
- **Rationale**: Đảm bảo dữ liệu sạch ngay từ cổng vào API.
- **Tác động**: Consumer phải format ID trước khi gửi (VD: `CAM-MAIN-01`).

### Issue 06: Mức độ bảo mật
- **Bối cảnh**: Các API có thể bị gọi trái phép.
- **Vấn đề**: Ai cũng có thể xem kết quả nhận diện.
- **Đề xuất**: Áp dụng Bearer Token (JWT) cho toàn bộ API, trả về `401 Unauthorized` nếu thiếu.
- **Quyết định**: Đồng ý.
- **Rationale**: Đảm bảo tính bảo mật cho hệ thống an ninh.
- **Tác động**: Cả 2 bên phải thêm xử lý token vào header.
=======
# Biên bản đàm phán hợp đồng API

- Cặp đàm phán: Core Business (Consumer) ↔ AI Vision (Provider)
- Product: Smart Campus Access và Security
- Provider: ai-vision-service
- Consumer: core-business-service
- Phiên: v1.0
- Ngày: 2026-05-19

---

## Issue #1

- Raised by: Consumer
- Endpoint: POST /vision/face-match
- Concern: Consumer cần hỗ trợ cả ảnh qua URL và embedding để phù hợp nhiều nguồn dữ liệu.
- Proposal: Thiết kế `FaceMatchRequest.input` là oneOf với discriminator `inputType`.
- Resolution: Accepted
- Rationale: Giữ contract linh hoạt và rõ ràng, vừa hỗ trợ imageRef vừa vector embedding.
- Impact: Provider cần hỗ trợ parsing oneOf và xác thực `inputType`.

---

## Issue #2

- Raised by: Provider
- Endpoint: POST /vision/face-match
- Concern: Khi model không chắc chắn, trả lỗi 422 sẽ làm Consumer mất thông tin khi vẫn cần audit.
- Proposal: Trả `LOW_CONFIDENCE` trong response 200 thay vì lỗi 422 cho trường hợp confidence thấp.
- Resolution: Accepted
- Rationale: Giữ synchronous flow và giúp Consumer phân biệt rõ giữa lỗi payload và kết quả phân tích thấp độ tin cậy.
- Impact: Consumer xử lý thêm trạng thái `LOW_CONFIDENCE` trong business logic.

---

## Issue #3

- Raised by: Consumer
- Endpoint: /vision/results/recent
- Concern: Consumer muốn xem kết quả gần nhất theo trang.
- Proposal: Thêm query parameter `cursor` + `limit` cho pagination.
- Resolution: Accepted
- Rationale: Cursor-based pagination phù hợp với log audit và tránh trùng lặp khi dữ liệu tăng.
- Impact: Provider cần trả `nextCursor` và `hasMore` trong response.

---

## Issue #4

- Raised by: Producer
- Endpoint: chung
- Concern: Nếu field có thể null thì hai bên phải đồng ý cách biểu diễn.
- Proposal: Dùng union type `[string, "null"]` thay vì `nullable: true`.
- Resolution: Accepted
- Rationale: Rule Lab 02 yêu cầu OpenAPI 3.1 dùng union type với null.
- Impact: Schema `matchedPersonId`, `detail`, `cursor` phải dùng union type.

---

## Issue #5

- Raised by: Consumer
- Endpoint: global
- Concern: Consumer cần biết chính xác nguyên nhân lỗi để hiển thị thông tin.
- Proposal: Chuẩn hóa response lỗi theo Problem Details `application/problem+json`.
- Resolution: Accepted
- Rationale: Giúp Consumer parse lỗi nhất quán và xử lý trường hợp 400/401/403/404/409/422/500.
- Impact: Provider cần trả schema `Problem` cho các response lỗi.

---

## Issue #6

- Raised by: Provider
- Endpoint: POST /vision/face-match
- Concern: Consumer muốn theo dõi request đông bộ giữa các hệ thống.
- Proposal: Bắt buộc `traceId` trong `FaceMatchRequest` và trả lại trong response.
- Resolution: Accepted
- Rationale: TraceId giúp đối chiếu log, bảo trì và debug khi nhiều request đồng thời.
- Impact: Consumer cần sinh traceId cho mỗi request và Provider phải echo lại traceId.

---

# Chốt hợp đồng v1.0

Provider sign-off: AI Vision Team
Consumer sign-off: Core Business Team
Witness (GV/TA): __________________
Date: 2026-05-19

---

## Ghi chú warning nếu Spectral còn cảnh báo

| Warning | Lý do chấp nhận tạm thời | Kế hoạch sửa |
|---|---|---|
|  |  |  |
>>>>>>> 45f52f59e2299856b27574d089c9f6fbc91febd6
