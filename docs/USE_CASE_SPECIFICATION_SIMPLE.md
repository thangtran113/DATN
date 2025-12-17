# ĐẶC TẢ USE CASE - WEB PHIM HỌC TIẾNG ANH

> **Lưu ý**: Luồng sự kiện chỉ mô tả tương tác giữa **User** và **Hệ thống**

---

## 1. ĐĂNG KÝ TÀI KHOẢN

**Tác nhân chính:** User

**Mục đích:** Tạo tài khoản mới để sử dụng hệ thống

**Điều kiện kích hoạt:** User nhấn nút "Đăng ký"

**Điều kiện tiên quyết:**

- Hệ thống đang hoạt động
- User có kết nối internet

**Điều kiện thành công:** Tài khoản được tạo, user đăng nhập tự động và chuyển đến trang Home

**Điều kiện thất bại:** Email đã tồn tại, mật khẩu không hợp lệ, lỗi kết nối

**Luồng sự kiện chính:**

1. User nhấn "Đăng ký"
2. Hệ thống hiển thị form (Email, Mật khẩu, Xác nhận mật khẩu, Họ tên)
3. User nhập thông tin và nhấn "Đăng ký"
4. Hệ thống validate và tạo tài khoản trên Firebase
5. Hệ thống lưu thông tin vào Firestore
6. Hệ thống đăng nhập tự động và chuyển đến Home
7. Hệ thống hiển thị "Đăng ký thành công"

**Luồng sự kiện thay thế:**

- User chọn "Đăng ký với Google" → Hệ thống xử lý OAuth → Tạo tài khoản và đăng nhập

**Luồng sự kiện ngoại lệ:**

- Email đã tồn tại → Hệ thống hiển thị lỗi → User nhập email khác
- Mật khẩu không hợp lệ → Hệ thống hiển thị yêu cầu → User nhập lại

---

## 2. ĐĂNG NHẬP

**Tác nhân chính:** User

**Mục đích:** Đăng nhập vào hệ thống

**Điều kiện kích hoạt:** User nhấn "Đăng nhập"

**Điều kiện tiên quyết:** User đã có tài khoản

**Điều kiện thành công:** User được xác thực và chuyển đến trang Home

**Điều kiện thất bại:** Email/mật khẩu sai, tài khoản bị khóa

**Luồng sự kiện chính:**

1. User nhấn "Đăng nhập"
2. Hệ thống hiển thị form đăng nhập
3. User nhập Email và Mật khẩu
4. Hệ thống xác thực với Firebase
5. Hệ thống lưu session và chuyển đến Home

**Luồng sự kiện thay thế:**

- User chọn "Đăng nhập với Google" → Hệ thống xử lý OAuth → Đăng nhập thành công

**Luồng sự kiện ngoại lệ:**

- Sai mật khẩu → Hệ thống hiển thị lỗi → User thử lại
- Tài khoản bị khóa → Hệ thống hiển thị thông báo và lý do

---

## 3. XEM DANH SÁCH PHIM

**Tác nhân chính:** User

**Mục đích:** Xem các phim có sẵn trong hệ thống

**Điều kiện kích hoạt:** User truy cập trang Home/Browse

**Điều kiện tiên quyết:** User đã đăng nhập

**Điều kiện thành công:** Danh sách phim hiển thị với poster, title, rating, level

**Điều kiện thất bại:** Không có phim, lỗi kết nối

**Luồng sự kiện chính:**

1. User truy cập trang Home
2. Hệ thống query danh sách phim từ Firestore
3. Hệ thống hiển thị phim dưới dạng grid (Featured, Popular, By Genres)
4. User scroll để xem thêm (lazy loading)
5. User click vào phim để xem chi tiết

**Luồng sự kiện thay thế:**

- User click vào Search → Chuyển sang use case "Tìm kiếm phim"
- User click Filter → Chuyển sang use case "Lọc phim"

**Luồng sự kiện ngoại lệ:**

- Không có phim → Hệ thống hiển thị "Chưa có phim nào"
- Lỗi kết nối → Hệ thống hiển thị lỗi với nút "Thử lại"

---

## 4. TÌM KIẾM PHIM

**Tác nhân chính:** User

**Mục đích:** Tìm phim theo từ khóa

**Điều kiện kích hoạt:** User click vào search bar

**Điều kiện tiên quyết:** User đã đăng nhập

**Điều kiện thành công:** Kết quả tìm kiếm hiển thị chính xác

**Điều kiện thất bại:** Không tìm thấy kết quả

**Luồng sự kiện chính:**

1. User click search bar
2. Hệ thống hiển thị search screen với recent/trending searches
3. User nhập từ khóa
4. Hệ thống tự động search (debounce 500ms)
5. Hệ thống hiển thị kết quả matching với title/genre/year
6. User click vào phim để xem chi tiết

**Luồng sự kiện thay thế:**

- User chọn từ recent search → Hệ thống tự động điền và search

**Luồng sự kiện ngoại lệ:**

- Không tìm thấy → Hệ thống hiển thị "Không tìm thấy phim" với gợi ý

---

## 5. XEM CHI TIẾT PHIM

**Tác nhân chính:** User

**Mục đích:** Xem thông tin chi tiết phim trước khi xem

**Điều kiện kích hoạt:** User click vào movie card

**Điều kiện tiên quyết:** Phim tồn tại trong database

**Điều kiện thành công:** Thông tin đầy đủ hiển thị

**Điều kiện thất bại:** Phim không tồn tại

**Luồng sự kiện chính:**

1. User click movie card
2. Hệ thống chuyển đến trang Movie Detail
3. Hệ thống load và hiển thị:
   - Backdrop, Title, Year, Duration, Rating, Level
   - Description, Cast, Director
   - Button "Xem ngay", "Trailer", "Watchlist"
   - Comments section
4. User có thể nhấn "Xem ngay" hoặc xem trailer/comments

**Luồng sự kiện thay thế:**

- User nhấn "Watchlist" → Hệ thống thêm vào danh sách yêu thích
- User nhấn "Trailer" → Hệ thống play trailer trong popup

**Luồng sự kiện ngoại lệ:**

- Phim không tồn tại → Hệ thống hiển thị "Phim không tồn tại" với nút quay lại

---

## 6. XEM PHIM

**Tác nhân chính:** User

**Mục đích:** Xem phim với phụ đề song ngữ và tính năng học tiếng Anh

**Điều kiện kích hoạt:** User nhấn "Xem ngay"

**Điều kiện tiên quyết:** Phim có videoUrl và subtitle files

**Điều kiện thành công:** Video phát với phụ đề song ngữ đồng bộ

**Điều kiện thất bại:** Video/subtitle không load được

**Luồng sự kiện chính:**

1. User nhấn "Xem ngay"
2. Hệ thống chuyển đến Video Player
3. Hệ thống load video và subtitle (EN + VI)
4. Hệ thống khởi tạo player với controls
5. Hệ thống phát video và hiển thị phụ đề song ngữ đồng bộ
6. User xem phim với các thao tác:
   - Click từ trong phụ đề → Tra từ điển
   - Play/Pause, Seek, Fullscreen
   - Điều chỉnh tốc độ
7. Hệ thống tự động lưu tiến độ mỗi 10 giây
8. Khi kết thúc → Hệ thống cập nhật history và hiển thị phim đề xuất

**Luồng sự kiện thay thế:**

- User click từ → Video pause → Hiển thị popup từ điển → User đóng → Video resume
- User thoát giữa chừng → Hệ thống lưu tiến độ → Quay lại trang chi tiết

**Luồng sự kiện ngoại lệ:**

- Video lỗi → Hệ thống hiển thị error với nút "Thử lại"
- Subtitle lỗi → Hệ thống hiển thị warning, vẫn phát video

---

## 7. TRA TỪ ĐIỂN

**Tác nhân chính:** User

**Mục đích:** Tra nghĩa từ trong phụ đề

**Điều kiện kích hoạt:** User click từ trong phụ đề

**Điều kiện tiên quyết:** User đang xem phim, phụ đề đang hiển thị

**Điều kiện thành công:** Từ điển hiển thị đầy đủ nghĩa, phiên âm, ví dụ

**Điều kiện thất bại:** Không tìm thấy từ, lỗi API

**Luồng sự kiện chính:**

1. User click vào từ trong phụ đề
2. Hệ thống pause video
3. Hệ thống gọi Dictionary API
4. Hệ thống hiển thị popup với:
   - Word, Phonetic, Part of speech
   - Definitions, Examples
   - Button "Lưu từ", "Phát âm", "Đóng"
5. User đọc định nghĩa
6. User đóng popup
7. Hệ thống resume video

**Luồng sự kiện thay thế:**

- User click "Phát âm" → Hệ thống phát audio phát âm
- User click "Lưu từ" → Chuyển use case "Lưu từ vựng"

**Luồng sự kiện ngoại lệ:**

- Không tìm thấy từ → Hệ thống hiển thị "Không tìm thấy từ"
- Lỗi API → Hệ thống hiển thị lỗi với nút "Thử lại"

---

## 8. LƯU TỪ VỰNG

**Tác nhân chính:** User

**Mục đích:** Lưu từ vào danh sách cá nhân để ôn tập

**Điều kiện kích hoạt:** User nhấn "Lưu từ vựng" trong popup từ điển

**Điều kiện tiên quyết:** User đã tra từ

**Điều kiện thành công:** Từ lưu vào Firestore, hiển thị "Đã lưu từ"

**Điều kiện thất bại:** Từ đã tồn tại, lỗi Firestore

**Luồng sự kiện chính:**

1. User click "Lưu từ vựng"
2. Hệ thống kiểm tra từ đã tồn tại chưa
3. Hệ thống lưu từ vào Firestore với thông tin:
   - Word, Meaning, Phonetic, Examples
   - MovieId, Timestamp, CreatedAt
4. Hệ thống hiển thị "Đã lưu từ"
5. Icon chuyển sang màu đỏ (đã lưu)

**Luồng sự kiện thay thế:**

- User click lại icon (bỏ lưu) → Hệ thống xóa từ Firestore → Icon về trắng

**Luồng sự kiện ngoại lệ:**

- Từ đã tồn tại → Hệ thống hiển thị "Từ đã có trong danh sách"
- Lỗi Firestore → Hệ thống hiển thị "Không thể lưu từ"

---

## 9. BÌNH LUẬN PHIM

**Tác nhân chính:** User

**Mục đích:** Viết bình luận và đánh giá phim

**Điều kiện kích hoạt:** User scroll xuống comment section

**Điều kiện tiên quyết:** User đã đăng nhập

**Điều kiện thành công:** Bình luận lưu vào Firestore và hiển thị

**Điều kiện thất bại:** Nội dung trống, quá dài

**Luồng sự kiện chính:**

1. User scroll xuống comment section
2. Hệ thống hiển thị danh sách comments và text field
3. User nhập nội dung và chọn rating (1-5 sao)
4. User nhấn "Gửi"
5. Hệ thống validate (không empty, < 500 ký tự)
6. Hệ thống lưu comment vào Firestore
7. Hệ thống cập nhật rating trung bình
8. Comment mới hiển thị ở đầu danh sách

**Luồng sự kiện thay thế:**

- User chỉ rating không comment → Hệ thống lưu rating → Cập nhật rating trung bình
- User like comment khác → Hệ thống tăng likes count

**Luồng sự kiện ngoại lệ:**

- Nội dung trống → Hệ thống hiển thị "Vui lòng nhập nội dung"
- Nội dung quá dài → Hệ thống hiển thị "Tối đa 500 ký tự"

---

## 10. QUẢN LÝ TÀI KHOẢN

**Tác nhân chính:** User

**Mục đích:** Xem và chỉnh sửa thông tin cá nhân

**Điều kiện kích hoạt:** User click avatar và chọn "Tài khoản của tôi"

**Điều kiện tiên quyết:** User đã đăng nhập

**Điều kiện thành công:** Thông tin hiển thị và cập nhật thành công

**Điều kiện thất bại:** Lỗi upload avatar, lỗi Firestore

**Luồng sự kiện chính:**

1. User click avatar
2. Hệ thống hiển thị dropdown menu
3. User chọn "Tài khoản của tôi"
4. Hệ thống hiển thị profile (Avatar, Name, Email, Statistics)
5. User click "Chỉnh sửa"
6. User thay đổi thông tin
7. User click "Lưu"
8. Hệ thống validate và cập nhật Firestore
9. Hệ thống hiển thị "Đã cập nhật"

**Luồng sự kiện thay thế:**

- User đổi avatar → Chọn ảnh → Hệ thống upload → Cập nhật photoURL
- User đổi mật khẩu → Nhập mật khẩu cũ/mới → Hệ thống cập nhật Firebase Auth

**Luồng sự kiện ngoại lệ:**

- Validation lỗi → Hệ thống hiển thị error → User sửa lại
- Lỗi cập nhật → Hệ thống hiển thị "Không thể cập nhật"

---

## 11. QUẢN LÝ PHIM (ADMIN)

**Tác nhân chính:** Admin

**Mục đích:** Thêm, sửa, xóa phim

**Điều kiện kích hoạt:** Admin vào Admin Panel

**Điều kiện tiên quyết:** Admin có quyền quản trị

**Điều kiện thành công:** Phim được thêm/sửa/xóa thành công

**Điều kiện thất bại:** Thiếu thông tin, lỗi upload

**Luồng sự kiện chính:**

1. Admin click "Thêm phim"
2. Hệ thống hiển thị form (Title, Description, Year, Level, Genres, etc.)
3. Admin điền thông tin và upload files (Poster, Video, Subtitles)
4. Admin click "Lưu"
5. Hệ thống validate
6. Hệ thống upload files lên Firebase Storage
7. Hệ thống tạo document trong Firestore
8. Hệ thống hiển thị "Đã thêm phim"

**Luồng sự kiện thay thế:**

- Sửa phim → Admin chọn phim → Hệ thống load data → Admin sửa → Hệ thống cập nhật
- Xóa phim → Admin xác nhận → Hệ thống xóa files và document

**Luồng sự kiện ngoại lệ:**

- Thiếu thông tin → Hệ thống highlight fields lỗi
- File không hợp lệ → Hệ thống hiển thị "File không hợp lệ"

---

## 12. QUẢN LÝ NGƯỜI DÙNG (ADMIN)

**Tác nhân chính:** Admin

**Mục đích:** Xem danh sách user, khóa/mở khóa tài khoản

**Điều kiện kích hoạt:** Admin vào "Quản lý người dùng"

**Điều kiện tiên quyết:** Admin có quyền quản trị

**Điều kiện thành công:** User được khóa/mở khóa thành công

**Điều kiện thất bại:** Lỗi cập nhật Firestore

**Luồng sự kiện chính:**

1. Admin click "Quản lý người dùng"
2. Hệ thống query và hiển thị bảng danh sách user
3. Admin có thể search, sort, filter
4. Admin click "Ban" trên 1 user
5. Hệ thống hiển thị dialog xác nhận
6. Admin nhập lý do (optional) và xác nhận
7. Hệ thống cập nhật isBanned = true trong Firestore
8. Status chuyển sang "Banned"
9. Hệ thống hiển thị "Đã khóa tài khoản"

**Luồng sự kiện thay thế:**

- Mở khóa → Admin click "Unban" → Hệ thống cập nhật isBanned = false
- Xem chi tiết → Admin click row → Hệ thống hiển thị modal với thông tin chi tiết

**Luồng sự kiện ngoại lệ:**

- Lỗi cập nhật → Hệ thống hiển thị "Không thể cập nhật trạng thái"

---

**HẾT**

_Tổng cộng: 12 Use Cases chính của hệ thống_
