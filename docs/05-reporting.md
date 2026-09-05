# 05 — Xuất PDF biên bản

Module: `Packages/Reporting`

**Đây là đầu ra người dùng trả tiền.** Không được cắt, không được xuất thiếu ảnh, không được
để một biên bản 40 trang crash ở trang 38.

## 1. Mục tiêu

Từ một `Session`, sinh ra file PDF biên bản có chữ ký hai bên, chia sẻ được qua Zalo/email ngay
tại chỗ, **không cần mạng**.

## 2. Phạm vi

**Trong phạm vi**

1. Trang bìa: tên công trình, địa chỉ, chủ đầu tư, ngày, người khảo sát.
2. Bảng tổng hợp: số lỗi theo mức độ, theo tầng.
3. Nội dung theo `Location`, mỗi `Issue` một khối: ảnh + mô tả + mức độ + hạn.
4. Cặp ảnh trước/sau đặt cạnh nhau cho lỗi đã ghép (xem [03-issue-tracking.md](03-issue-tracking.md)).
5. Mục riêng "Lỗi tồn quá 3 đợt".
6. Trang chữ ký: hai ô ký tay trên màn hình, ghi tên + chức danh + thời điểm ký.
7. Footer mỗi trang: mã biên bản, số trang, và **8 ký tự đầu của SHA-256** từng ảnh dưới ảnh đó.
8. Xuất ra `Files`, `UIActivityViewController`.

**Ngoài phạm vi**

1. Template tuỳ biến của từng công ty (v2).
2. Ký số PKI. Chữ ký ở đây là chữ ký tay chụp lại, có giá trị nghiệm thu nội bộ, không phải
   chữ ký điện tử pháp lý — **nói rõ điều này trong app**, đừng để người dùng hiểu nhầm.

## 3. Kỹ thuật sinh PDF

`UIGraphicsPDFRenderer`, không dùng thư viện ngoài, không dùng WebView + `print`.

Lý do loại WebView: HTML→PDF phụ thuộc timing load ảnh, và với 200 ảnh thì hoặc là chậm khủng
khiếp hoặc là ra trang trắng. `UIGraphicsPDFRenderer` cho kiểm soát trực tiếp và **quan trọng
nhất là cho phép vẽ từng trang rồi thả ảnh ra khỏi RAM**.

### Bộ nhớ — ràng buộc quyết định thiết kế

Một biên bản 40 trang × 4 ảnh = 160 ảnh. Nạp full-size hết một lượt là **chắc chắn bị jetsam
kill**. Quy tắc:

1. Ảnh đưa vào PDF là **downsample bằng `CGImageSourceCreateThumbnailAtIndex`** với
   `kCGImageSourceThumbnailMaxPixelSize`, không phải `UIImage(contentsOfFile:)` rồi resize.
2. Downsample tới đúng kích thước ô in (`maxImagePixelSize`), không hơn.
3. Vẽ xong một trang thì **giải phóng ảnh của trang đó ngay**, mỗi trang một `autoreleasepool`.
4. Render trên background queue, `@MainActor` chỉ nhận progress.

```swift
for (index, page) in pages.enumerated() {
    autoreleasepool {
        context.beginPage()
        renderer.draw(page, in: context)
    }
    await progress.send(Double(index + 1) / Double(pages.count))
}
```

### Layout

Tách hai pha rõ ràng:

```
SessionSnapshot → ReportLayoutEngine → [ReportPage] → PDFPageRenderer → PDF
                  (thuần, không UIKit)                 (UIKit, vẽ)
```

`ReportLayoutEngine` là code thuần trong `Reporting`: nhận snapshot, tính ra danh sách trang và
vị trí từng khối. **Không import UIKit**, nên test được hoàn toàn — assert số trang, thứ tự,
không có issue nào bị rơi, không có khối nào tràn.

Đây là cách duy nhất để đảm bảo "không xuất thiếu ảnh": đếm ở tầng layout, không đếm ở tầng vẽ.

## 4. Chữ ký

1. `PencilKit` (`PKCanvasView`) hoặc `UIBezierPath` tự vẽ — cả hai đều được, `PencilKit` rẻ hơn.
2. Xuất ra PNG nền trong suốt, nhúng vào trang cuối.
3. Lưu kèm `signedAt`, `signerName`, `signerRole` cho từng bên.
4. **Ký xong thì `Session.state = .exported`** và session thành chỉ đọc. Sửa sau khi ký là thứ
   phá giá trị của biên bản.
5. Ký lại (do sai tên) → phải tạo bản sửa đổi mới, mã biên bản có hậu tố `-R2`, bản cũ giữ nguyên.

## 5. Toàn vẹn

Footer in 8 ký tự đầu SHA-256 của mỗi ảnh, và trang cuối in **hash của toàn bộ danh sách hash**
(Merkle-style, đơn giản: SHA-256 của chuỗi các hash đã sắp theo `captureID`).

Nghĩa là: bên nhận biên bản có thể yêu cầu file gốc và tự kiểm chứng ảnh trong PDF chưa bị thay.
Đó là toàn bộ lý do app này ghi hash ngay lúc chụp ([02-capture.md](02-capture.md)).

## 6. Constants

```swift
enum ReportConstants {
    static let pageSize: CGSize = CGSize(width: 595, height: 842)   // A4 @72dpi
    static let margin: CGFloat = 40
    static let imagesPerRow: Int = 2
    static let maxImagePixelSize: CGFloat = 1400
    static let jpegCompressionQuality: CGFloat = 0.8
    static let hashPrefixLength: Int = 8
    static let staleIssueSessionThreshold: Int = 3
}
```

Mọi spacing/màu/font qua `DesignSystem` token, kể cả trong PDF — biên bản là mặt tiền của sản
phẩm và không được lệch với UI.

## 7. Rủi ro đã biết

1. **Bị kill giữa lúc render** biên bản lớn. Render ra file tạm rồi `moveItem` atomically; file
   dở không bao giờ lộ ra cho người dùng.
2. **Ảnh trên disk đã mất** (người dùng dọn dẹp, restore backup lỗi). Layout engine phải xử lý
   `Capture` thiếu file: in ô placeholder ghi rõ "Ảnh không còn trên thiết bị — {hash}", **không
   crash và không im lặng bỏ qua**.
3. **Tên tiếng Việt có dấu** trong tên file → dùng `addingPercentEncoding` khi share, và test
   với tên "Chung cư Ánh Dương – Block B".
4. **PDF vài trăm MB** không gửi được qua Zalo. Hiện dung lượng ước tính trước khi export và cho
   chọn mức nén.

## 8. Definition of done

1. Session 200 ảnh / 40 lỗi → PDF xuất xong trên iPhone đời thấp, **RAM đỉnh < 200MB**, không crash.
2. Số ảnh trong PDF **bằng đúng** số `Capture` không bị `isExcludedFromReport`. Đếm bằng test,
   không đếm bằng mắt.
3. Cặp trước/sau đúng cặp, đúng thứ tự, có nhãn `Location.code` dưới mỗi ảnh.
4. Xuất ở chế độ máy bay thành công.
5. Zero warning.

## 9. Test

| Test | Loại |
|---|---|
| `ReportLayoutEngine`: tổng số ảnh in ra == số capture đầu vào, không sót | unit, thuần |
| Session rỗng / 1 issue / 500 issue → không crash, số trang hợp lý | unit |
| Issue có 20 ảnh không tràn khỏi khối, chia trang đúng | unit |
| Capture thiếu file trên disk → sinh placeholder, không throw | unit |
| Merkle hash của danh sách ổn định khi đổi thứ tự đầu vào | unit |
| Render 200 ảnh, đo RAM đỉnh | performance, `XCTMemoryMetric` |
| PDF mở được bằng Preview/Acrobat, không lỗi font | manual, checklist |
