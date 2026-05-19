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
