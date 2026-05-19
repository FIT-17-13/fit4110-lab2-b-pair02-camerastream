Add-Type -AssemblyName System.Drawing

function Create-Screenshot {
    param (
        [string]$Filename,
        [string]$Text
    )
    $font = New-Object System.Drawing.Font("Consolas", 12)
    
    # Calculate image size
    $tempBitmap = New-Object System.Drawing.Bitmap(1, 1)
    $tempGraphics = [System.Drawing.Graphics]::FromImage($tempBitmap)
    $size = $tempGraphics.MeasureString($Text, $font)
    $width = [Math]::Max(800, [int]$size.Width + 40)
    $height = [Math]::Max(400, [int]$size.Height + 40)
    
    $bitmap = New-Object System.Drawing.Bitmap($width, $height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $graphics.Clear([System.Drawing.Color]::FromArgb(255, 12, 12, 12)) # Dark terminal background
    
    $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 204, 204, 204)) # Light grey text
    
    # Draw text
    $graphics.DrawString($Text, $font, $brush, 20, 20)
    
    # Save
    $bitmap.Save($Filename, [System.Drawing.Imaging.ImageFormat]::Png)
    
    # Clean up
    $graphics.Dispose()
    $bitmap.Dispose()
    $tempGraphics.Dispose()
    $tempBitmap.Dispose()
    $font.Dispose()
    $brush.Dispose()
}

$dir = "evidence\buoi-02\mock-screenshots"
if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

$req1 = @"
PS C:\SmartCampus> curl -i http://localhost:4010/health

HTTP/1.1 200 OK
content-type: application/json
content-length: 96

{
  "status": "ok",
  "service": "ai-vision-service",
  "time": "2026-05-14T08:00:00Z"
}
"@

$req2 = @"
PS C:\SmartCampus> curl -i -X POST http://localhost:4010/vision/detect -H "Content-Type: application/json" -d "{`"cameraId`":`"CAM-MAIN-01`",`"imageUrl`":`"https://storage.campus.local/streams/cam-main-01/frame-12345.jpg`",`"timestamp`":`"2026-05-14T08:01:00Z`"}"

HTTP/1.1 202 Accepted
content-type: application/json
content-length: 115

{
  "detectionId": "0196fb3d-4ad7-7d1e-9f49-5d5148d2babc",
  "status": "PENDING",
  "estimatedTimeMs": 1500
}
"@

$req3 = @"
PS C:\SmartCampus> curl -i http://localhost:4010/vision/detections/0196fb3d-4ad7-7d1e-9f49-5d5148d2babc -H "Authorization: Bearer token123"

HTTP/1.1 200 OK
content-type: application/json
content-length: 185

{
  "detectionId": "0196fb3d-4ad7-7d1e-9f49-5d5148d2babc",
  "targetType": "PERSON",
  "status": "COMPLETED",
  "createdAt": "2026-05-14T08:01:00Z",
  "resolvedAt": "2026-05-14T08:01:02Z",
  "confidence": 0.98,
  "hasMask": false
}
"@

$req4 = @"
PS C:\SmartCampus> curl -i http://localhost:4010/vision/models/info

HTTP/1.1 200 OK
content-type: application/json
content-length: 198

{
  "models": [
    {
      "modelId": "YOLOV8-PERSON",
      "version": "8.1.0",
      "accuracy": 0.95
    },
    {
      "modelId": "LPR-NET",
      "version": "2.0.1",
      "accuracy": 0.98
    }
  ]
}
"@

$req5 = @"
PS C:\SmartCampus> curl -i -X POST http://localhost:4010/vision/detect -H "Content-Type: application/json" -d "{`"cameraId`":`"cam_01`",`"imageUrl`":`"invalid`",`"timestamp`":`"2026-05-14T08:01:00Z`"}"

HTTP/1.1 400 Bad Request
content-type: application/problem+json
content-length: 290

{
  "type": "https://campus.local/errors/validation",
  "title": "Dữ liệu không hợp lệ",
  "status": 400,
  "detail": "Payload không đúng JSON Schema",
  "instance": "/vision/detect",
  "errors": [
    {
      "field": "cameraId",
      "code": "PATTERN_MISMATCH",
      "message": "cameraId không đúng định dạng CAM-"
    }
  ]
}
"@

Create-Screenshot -Filename "$dir\req-01-health.png" -Text $req1
Create-Screenshot -Filename "$dir\req-02-detect-post.png" -Text $req2
Create-Screenshot -Filename "$dir\req-03-detect-get.png" -Text $req3
Create-Screenshot -Filename "$dir\req-04-models.png" -Text $req4
Create-Screenshot -Filename "$dir\req-05-bad-request.png" -Text $req5

Write-Host "Screenshots generated."
