# ĐẶC TẢ USE CASE - WEB PHIM HỌC TIẾNG ANH

> **Lưu ý**: Luồng sự kiện được mô tả đơn giản với 2 tác nhân chính: **User** (Người dùng) và **Hệ thống**

---

## 1. USE CASE: ĐĂNG KÝ TÀI KHOẢN

### Tên Use Case

Đăng ký tài khoản

### Tác nhân chính

User (Người dùng)

### Mục đích

Cho phép người dùng tạo tài khoản mới để sử dụng các tính năng của hệ thống

### Điều kiện kích hoạt

- User truy cập vào trang web
- User nhấn nút "Đăng ký" trên màn hình đăng nhập

### Điều kiện tiên quyết

- Hệ thống đang hoạt động bình thường
- User có kết nối internet
- Firebase Authentication đang hoạt động

### Điều kiện thành công

- Tài khoản mới được tạo thành công trong Firebase
- Thông tin user được lưu vào Firestore
- User được tự động đăng nhập và chuyển đến trang chủ
- Email xác thực được gửi đến user (tùy chọn)

### Điều kiện thất bại

- Email đã tồn tại trong hệ thống
- Mật khẩu không đáp ứng yêu cầu bảo mật (dưới 6 ký tự)
- Thông tin không hợp lệ (email sai định dạng)
- Lỗi kết nối Firebase
- Mất kết nối internet

### Luồng sự kiện chính

1. User nhấn nút "Đăng ký"
2. Hệ thống hiển thị form đăng ký (Email, Mật khẩu, Xác nhận mật khẩu, Họ tên)
3. User nhập thông tin và nhấn "Đăng ký"
4. Hệ thống validate dữ liệu
5. Hệ thống tạo tài khoản trên Firebase Authentication
6. Hệ thống lưu thông tin user vào Firestore
7. Hệ thống tự động đăng nhập và chuyển đến trang Home
8. Hệ thống hiển thị thông báo "Đăng ký thành công"

### Luồng sự kiện thay thế

**Đăng ký bằng Google:**

1. User nhấn "Đăng ký với Google"
2. Hệ thống mở popup Google Sign-In
3. User chọn tài khoản Google
4. Hệ thống tạo tài khoản và đăng nhập tự động
5. Hệ thống chuyển đến trang Home

### Luồng sự kiện ngoại lệ

**Email đã tồn tại:**

- Hệ thống hiển thị "Email này đã được đăng ký"
- User có thể chọn đăng nhập hoặc nhập email khác

**Dữ liệu không hợp lệ:**

- Hệ thống hiển thị lỗi validation
- User sửa lại thông tin và thử lại

---

## 2. USE CASE: ĐĂNG NHẬP

### Tên Use Case

Đăng nhập

### Tác nhân chính

User (Người dùng)

### Mục đích

Cho phép người dùng đăng nhập vào hệ thống để sử dụng các tính năng

### Điều kiện kích hoạt

- User truy cập vào trang web
- User nhấn nút "Đăng nhập"

### Điều kiện tiên quyết

- User đã có tài khoản trong hệ thống
- Hệ thống đang hoạt động bình thường
- Firebase Authentication đang hoạt động

### Điều kiện thành công

- Thông tin đăng nhập được xác thực thành công
- Session/token được lưu trữ
- lastLoginAt được cập nhật trong Firestore
- User được chuyển đến trang Home

### Điều kiện thất bại

- Email không tồn tại
- Mật khẩu không chính xác
- Tài khoản bị khóa/ban
- Lỗi kết nối

### Luồng sự kiện chính

1. User nhấn nút "Đăng nhập"
2. Hệ thống hiển thị form đăng nhập (Email, Mật khẩu)
3. User nhập thông tin và nhấn "Đăng nhập"
4. Hệ thống xác thực với Firebase Authentication
5. Hệ thống lấy thông tin user từ Firestore và lưu session
6. Hệ thống chuyển đến trang Home
7. Hệ thống hiển thị "Đăng nhập thành công"

### Luồng sự kiện thay thế

**Đăng nhập bằng Google:**

1. User nhấn "Đăng nhập với Google"
2. Hệ thống mở popup Google Sign-In
3. User chọn tài khoản
4. Hệ thống xác thực và chuyển đến trang Home

### Luồng sự kiện ngoại lệ

**Thông tin không đúng:**

- Hệ thống hiển thị "Email hoặc mật khẩu không đúng"
- User có thể thử lại hoặc chọn "Quên mật khẩu"

**Tài khoản bị khóa:**

- Hệ thống hiển thị "Tài khoản đã bị khóa" và lý do
- User không thể đăng nhập

---

## 3. USE CASE: XEM DANH SÁCH PHIM

### Tên Use Case

Xem danh sách phim

### Tác nhân chính

User (Người dùng)

### Mục đích

Cho phép user xem danh sách các phim có sẵn trong hệ thống để chọn phim muốn xem

### Điều kiện kích hoạt

- User truy cập trang Home sau khi đăng nhập
- User nhấn vào tab "Browse" hoặc "Movies"

### Điều kiện tiên quyết

- User đã đăng nhập
- Hệ thống có ít nhất 1 phim trong database

### Điều kiện thành công

- Danh sách phim được hiển thị thành công
- User có thể xem thông tin cơ bản của mỗi phim (poster, title, rating, level)
- Danh sách được phân trang hoặc lazy load

### Điều kiện thất bại

- Không có phim nào trong database
- Lỗi kết nối Firestore
- Lỗi load hình ảnh

### Luồng sự kiện chính

1. User truy cập trang Home/Browse
2. Hệ thống hiển thị loading indicator
3. Hệ thống query danh sách phim từ Firestore collection "movies"
4. Hệ thống sắp xếp phim theo:
   - Featured movies (nổi bật)
   - Popular movies (phổ biến)
   - By genres (theo thể loại)
5. Hệ thống hiển thị danh sách phim dưới dạng grid
6. Mỗi movie card hiển thị:
   - Poster image
   - Title
   - Rating (sao)
   - Level (Beginner/Intermediate/Advanced)
   - Duration
7. User có thể scroll để xem thêm phim (lazy loading)
8. User click vào 1 phim để xem chi tiết

### Luồng sự kiện thay thế

**LSK 1a: User muốn tìm kiếm phim**

1. User click vào search bar
2. Chuyển sang use case "Tìm kiếm phim"

**LSK 1b: User muốn lọc phim**

1. User click vào filter button
2. Chuyển sang use case "Lọc phim theo level"

**LSK 7a: User scroll đến cuối danh sách**

1. Hệ thống phát hiện user scroll gần cuối trang
2. Hệ thống tự động load thêm phim (pagination)
3. Hiển thị loading indicator
4. Append phim mới vào danh sách
5. Quay lại bước 6

### Luồng sự kiện ngoại lệ

**LSK 3a: Không có phim nào**

1. Firestore trả về empty array
2. Hệ thống hiển thị empty state:
   - Icon phim
   - Text "Chưa có phim nào"
   - Button "Reload"
3. Use case kết thúc

**LSK 3b: Lỗi kết nối**

1. Không thể query Firestore
2. Hệ thống hiển thị error message
3. Hiển thị button "Thử lại"
4. User có thể retry hoặc thoát

**LSK 6a: Lỗi load poster image**

1. Hình ảnh poster không load được
2. Hệ thống hiển thị placeholder image mặc định
3. Vẫn hiển thị các thông tin khác của phim

---

## 4. USE CASE: TÌM KIẾM PHIM

### Tên Use Case

Tìm kiếm phim

### Tác nhân chính

User (Người dùng)

### Mục đích

Cho phép user tìm kiếm phim theo từ khóa (title, genre, year)

### Điều kiện kích hoạt

- User click vào search bar
- User nhập từ khóa tìm kiếm

### Điều kiện tiên quyết

- User đã đăng nhập
- Có phim trong database

### Điều kiện thành công

- Kết quả tìm kiếm được hiển thị chính xác
- User có thể click vào phim trong kết quả

### Điều kiện thất bại

- Không tìm thấy phim nào phù hợp
- Lỗi query

### Luồng sự kiện chính

1. User click vào search bar
2. Hệ thống mở search screen với:
   - Search input field (focus tự động)
   - Recent searches (nếu có)
   - Trending searches
3. User nhập từ khóa
4. Hệ thống tự động search khi user gõ (debounce 500ms)
5. Hệ thống query Firestore với điều kiện:
   - Title contains keyword (case-insensitive)
   - Genre matches keyword
   - Year matches keyword
6. Hệ thống hiển thị kết quả tìm kiếm
7. User click vào phim muốn xem
8. Chuyển sang use case "Xem chi tiết phim"

### Luồng sự kiện thay thế

**LSK 3a: User chọn từ recent search**

1. User click vào 1 item trong "Recent searches"
2. Hệ thống tự động điền từ khóa vào search bar
3. Quay lại bước 4 của luồng chính

**LSK 3b: User xóa search query**

1. User click nút "Clear" hoặc xóa hết text
2. Hệ thống ẩn kết quả tìm kiếm
3. Hiển thị lại recent/trending searches
4. Quay lại bước 2

### Luồng sự kiện ngoại lệ

**LSK 6a: Không tìm thấy kết quả**

1. Firestore trả về empty array
2. Hệ thống hiển thị:
   - Icon search
   - Text "Không tìm thấy phim '{keyword}'"
   - Gợi ý "Thử tìm với từ khóa khác"
3. User có thể nhập từ khóa mới

---

## 5. USE CASE: XEM CHI TIẾT PHIM

### Tên Use Case

Xem chi tiết phim

### Tác nhân chính

User (Người dùng)

### Mục đích

Cho phép user xem thông tin chi tiết về phim trước khi quyết định xem

### Điều kiện kích hoạt

- User click vào movie card từ danh sách phim
- User click vào phim từ kết quả tìm kiếm

### Điều kiện tiên quyết

- User đã đăng nhập
- Phim tồn tại trong database

### Điều kiện thành công

- Thông tin chi tiết phim được hiển thị đầy đủ
- User có thể xem trailer (nếu có)
- User có thể nhấn nút "Xem ngay"

### Điều kiện thất bại

- Phim không tồn tại
- Lỗi load dữ liệu

### Luồng sự kiện chính

1. User click vào movie card
2. Hệ thống chuyển đến trang Movie Detail
3. Hệ thống hiển thị loading
4. Hệ thống query thông tin chi tiết từ Firestore
5. Hệ thống hiển thị:
   - Backdrop image (lớn)
   - Title
   - Year, Duration, Rating
   - Level (Beginner/Intermediate/Advanced)
   - Genres (tags)
   - Description
   - Cast & Director
   - Button "Xem ngay"
   - Button "Trailer" (nếu có)
   - Button "Thêm vào Watchlist"
   - Comments section
6. User có thể:
   - Nhấn "Xem ngay" → Chuyển sang use case "Xem phim"
   - Nhấn "Trailer" → Play trailer
   - Nhấn "Watchlist" → Thêm vào danh sách yêu thích
   - Scroll xuống xem comments
   - Viết comment/rating

### Luồng sự kiện thay thế

**LSK 6a: User nhấn "Xem ngay"**

1. User click button "Xem ngay"
2. Hệ thống kiểm tra xem user đã xem phim này chưa
3. Nếu đã xem → Hiển thị dialog "Tiếp tục từ [timestamp]?"
4. Chuyển sang use case "Xem phim"

**LSK 6b: User nhấn "Thêm vào Watchlist"**

1. User click icon bookmark/heart
2. Hệ thống thêm movieId vào user.watchlist trong Firestore
3. Icon chuyển sang trạng thái "đã thêm"
4. Hiển thị snackbar "Đã thêm vào Watchlist"

**LSK 6c: User nhấn "Play Trailer"**

1. User click button "Trailer"
2. Hệ thống mở popup video player
3. Play trailer từ URL
4. User có thể đóng popup bất kỳ lúc nào

### Luồng sự kiện ngoại lệ

**LSK 4a: Phim không tồn tại**

1. Firestore trả về null/undefined
2. Hệ thống hiển thị "Phim không tồn tại"
3. Hiển thị button "Quay lại"
4. Use case kết thúc

---

## 6. USE CASE: XEM PHIM

### Tên Use Case

Xem phim

### Tác nhân chính

User (Người dùng)

### Mục đích

Cho phép user xem phim với phụ đề song ngữ và các tính năng hỗ trợ học tiếng Anh

### Điều kiện kích hoạt

- User nhấn nút "Xem ngay" từ trang chi tiết phim
- User tiếp tục xem phim từ lịch sử

### Điều kiện tiên quyết

- User đã đăng nhập
- Phim có videoUrl hợp lệ
- Phim có subtitle files

### Điều kiện thành công

- Video được phát thành công
- Phụ đề song ngữ hiển thị đồng bộ
- User có thể tương tác với phụ đề (click từ)
- Tiến độ xem được lưu tự động

### Điều kiện thất bại

- Video không load được
- Subtitle không đồng bộ
- Lỗi kết nối

### Luồng sự kiện chính

1. User nhấn "Xem ngay"
2. Hệ thống chuyển đến Video Player screen
3. Hệ thống load:
   - Video từ Firebase Storage
   - Subtitle files (EN + VI)
4. Hệ thống khởi tạo video player với:
   - Video controls (play/pause/seek/fullscreen)
   - Subtitle display area
   - Dictionary integration
5. Video bắt đầu phát
6. Hệ thống hiển thị phụ đề song ngữ đồng bộ theo timestamp:
   - Tiếng Anh (trên)
   - Tiếng Việt (dưới)
7. User xem phim và có thể:
   - Click từ trong phụ đề → Tra từ điển
   - Pause/play video
   - Seek đến vị trí khác
   - Toggle fullscreen
   - Điều chỉnh tốc độ phát
8. Hệ thống tự động lưu tiến độ xem mỗi 10 giây
9. Khi video kết thúc:
   - Cập nhật watch history
   - Hiển thị "Phim đề xuất"
   - Button "Xem lại"

### Luồng sự kiện thay thế

**LSK 7a: User click từ trong phụ đề**

1. User click vào 1 từ trong subtitle
2. Video tự động pause
3. Hệ thống gọi Dictionary API
4. Hiển thị popup từ điển với:
   - Word
   - Phonetic
   - Definitions
   - Examples
   - Button "Lưu từ"
   - Button "Phát âm"
5. User đọc định nghĩa
6. User đóng popup → Video tự động resume
7. Chuyển sang use case "Tra từ điển"

**LSK 7b: User muốn lưu từ vựng**

- Xem use case "Lưu từ vựng"

**LSK 9a: User thoát giữa chừng**

1. User nhấn nút Back
2. Hệ thống pause video
3. Lưu currentTime vào watch history
4. Quay lại trang chi tiết phim

### Luồng sự kiện ngoại lệ

**LSK 3a: Video không load được**

1. Video player báo lỗi load video
2. Hệ thống hiển thị error message
3. Hiển thị button "Thử lại" và "Quay lại"
4. User có thể retry hoặc thoát

**LSK 3b: Subtitle không có hoặc lỗi format**

1. Subtitle file không tồn tại hoặc parse lỗi
2. Hệ thống vẫn phát video
3. Hiển thị warning "Phụ đề không khả dụng"
4. User có thể tiếp tục xem không có phụ đề

---

## 7. USE CASE: TRA TỪ ĐIỂN

### Tên Use Case

Tra từ điển từ phụ đề

### Tác nhân chính

User (Người dùng)

### Mục đích

Cho phép user tra nghĩa của từ trong phụ đề để học từ vựng

### Điều kiện kích hoạt

- User click vào 1 từ trong phụ đề khi đang xem phim

### Điều kiện tiên quyết

- User đang xem phim
- Phụ đề đang hiển thị
- Dictionary API đang hoạt động

### Điều kiện thành công

- Từ điển hiển thị đầy đủ thông tin: nghĩa, phiên âm, ví dụ
- User có thể nghe phát âm
- User có thể lưu từ vào danh sách từ vựng

### Điều kiện thất bại

- Không tìm thấy từ trong từ điển
- Lỗi kết nối API
- Từ không hợp lệ

### Luồng sự kiện chính

1. User click vào 1 từ trong phụ đề (VD: "adventure")
2. Video tự động pause
3. Hệ thống extract word từ subtitle text
4. Hệ thống call Dictionary API với word
5. API trả về:
   - Word: "adventure"
   - Phonetic: /ədˈven.tʃər/
   - Part of speech: noun
   - Definitions: [...]
   - Examples: [...]
   - Synonyms/Antonyms
6. Hệ thống hiển thị popup từ điển với layout:
   ```
   ┌─────────────────────────────┐
   │ Adventure        🔊  ❤️      │
   │ /ədˈven.tʃər/              │
   │                             │
   │ Noun                        │
   │ • An unusual, exciting      │
   │   experience                │
   │ • Example: "a spirit of     │
   │   adventure"                │
   │                             │
   │ [Lưu từ vựng]    [Đóng]     │
   └─────────────────────────────┘
   ```
7. User đọc định nghĩa
8. User click nút "Đóng"
9. Popup đóng lại
10. Video tự động resume

### Luồng sự kiện thay thế

**LSK 7a: User muốn nghe phát âm**

1. User click icon 🔊 (speaker)
2. Hệ thống gọi Text-to-Speech API
3. Phát âm thanh của từ
4. Quay lại bước 7

**LSK 7b: User muốn lưu từ**

1. User click button "Lưu từ vựng" hoặc icon ❤️
2. Chuyển sang use case "Lưu từ vựng"

**LSK 7c: User click bên ngoài popup**

1. User click vào overlay (vùng tối bên ngoài popup)
2. Popup đóng lại
3. Video resume
4. Use case kết thúc

### Luồng sự kiện ngoại lệ

**LSK 4a: Không tìm thấy từ**

1. Dictionary API trả về 404 hoặc null
2. Hệ thống hiển thị:
   - "Không tìm thấy từ '{word}' trong từ điển"
   - "Bạn có muốn tìm từ khác?"
3. Button "Đóng"
4. Use case kết thúc

**LSK 4b: Lỗi kết nối API**

1. Request timeout hoặc network error
2. Hệ thống hiển thị:
   - "Không thể kết nối đến từ điển"
   - Button "Thử lại"
3. User có thể retry hoặc đóng

---

## 8. USE CASE: LƯU TỪ VỰNG

### Tên Use Case

Lưu từ vựng

### Tác nhân chính

User (Người dùng)

### Mục đích

Cho phép user lưu từ vựng vào danh sách cá nhân để ôn tập sau

### Điều kiện kích hoạt

- User click nút "Lưu từ vựng" trong popup từ điển

### Điều kiện tiên quyết

- User đã tra từ trong từ điển
- User đang xem popup định nghĩa từ

### Điều kiện thành công

- Từ được lưu vào Firestore collection "vocabulary"
- Hiển thị thông báo "Đã lưu từ"
- Icon trái tim chuyển sang màu đỏ

### Điều kiện thất bại

- Từ đã tồn tại trong danh sách
- Lỗi kết nối Firestore

### Luồng sự kiện chính

1. User click button "Lưu từ vựng" hoặc icon ❤️
2. Hệ thống kiểm tra từ đã tồn tại trong danh sách chưa
3. Hệ thống tạo document mới trong Firestore:
   ```
   vocabulary/{userId}/{wordId}
   {
     word: "adventure",
     meaning: "...",
     phonetic: "/ədˈven.tʃər/",
     examples: [...],
     movieId: "movie123",
     timestamp: "00:15:32",
     createdAt: timestamp,
     reviewCount: 0,
     lastReviewed: null,
     masteryLevel: 0
   }
   ```
4. Hệ thống lưu vào Firestore
5. Icon ❤️ chuyển sang màu đỏ (filled)
6. Hiển thị snackbar "Đã lưu từ 'adventure'"
7. User tiếp tục xem định nghĩa hoặc đóng popup

### Luồng sự kiện thay thế

**LSK 2a: Từ đã tồn tại**

1. Hệ thống phát hiện từ đã có trong vocabulary
2. Hiển thị snackbar "Từ này đã có trong danh sách"
3. Icon ❤️ vẫn giữ màu đỏ
4. Use case kết thúc

**LSK 7a: User muốn xóa từ đã lưu**

1. User click lại icon ❤️ (đã filled)
2. Hệ thống xóa document khỏi Firestore
3. Icon ❤️ chuyển về màu trắng (outline)
4. Hiển thị snackbar "Đã xóa khỏi danh sách"

### Luồng sự kiện ngoại lệ

**LSK 4a: Lỗi lưu vào Firestore**

1. Firestore báo lỗi (permission, network)
2. Hệ thống hiển thị snackbar "Không thể lưu từ. Thử lại"
3. Icon ❤️ không đổi màu
4. Use case kết thúc

---

## 9. USE CASE: BÌNH LUẬN PHIM

### Tên Use Case

Bình luận phim

### Tác nhân chính

User (Người dùng)

### Mục đích

Cho phép user viết bình luận và đánh giá phim

### Điều kiện kích hoạt

- User scroll xuống comment section trong trang chi tiết phim
- User click vào "Viết bình luận"

### Điều kiện tiên quyết

- User đã đăng nhập
- User đang ở trang chi tiết phim

### Điều kiện thành công

- Bình luận được lưu vào Firestore
- Bình luận hiển thị trong danh sách comments
- Rating được cập nhật (nếu có)

### Điều kiện thất bại

- Nội dung bình luận trống
- Nội dung vi phạm (spam, nội dung xấu)
- Lỗi kết nối

### Luồng sự kiện chính

1. User scroll xuống comment section
2. Hệ thống hiển thị:
   - Danh sách comments hiện có
   - Rating trung bình
   - Text field "Viết bình luận..."
   - Rating stars (1-5)
3. User click vào text field
4. Hệ thống expand comment input area
5. User nhập nội dung bình luận
6. User chọn rating (1-5 sao) - tùy chọn
7. User click nút "Gửi"
8. Hệ thống validate:
   - Content không empty
   - Content length < 500 ký tự
9. Hệ thống tạo document mới:
   ```
   comments/{commentId}
   {
     movieId: "movie123",
     userId: "user456",
     userName: "John Doe",
     userAvatar: "...",
     content: "Great movie!",
     rating: 5,
     createdAt: timestamp,
     likes: 0,
     replies: []
   }
   ```
10. Hệ thống lưu vào Firestore
11. Hệ thống cập nhật rating trung bình của phim
12. Comment mới xuất hiện ở đầu danh sách
13. Hiển thị snackbar "Đã gửi bình luận"

### Luồng sự kiện thay thế

**LSK 5a: User chỉ muốn rating, không comment**

1. User chọn số sao (1-5)
2. User không nhập text
3. User click nút "Gửi"
4. Hệ thống chỉ lưu rating
5. Cập nhật rating trung bình
6. Hiển thị "Cảm ơn bạn đã đánh giá"

**LSK 13a: User muốn like comment khác**

1. User click icon 👍 trên comment
2. Hệ thống tăng likes count
3. Icon chuyển sang màu xanh
4. Cập nhật Firestore

### Luồng sự kiện ngoại lệ

**LSK 8a: Nội dung trống**

1. User click "Gửi" mà chưa nhập gì
2. Hệ thống hiển thị error "Vui lòng nhập nội dung"
3. Focus vào text field
4. Quay lại bước 5

**LSK 8b: Nội dung quá dài**

1. Nội dung > 500 ký tự
2. Hiển thị "Bình luận tối đa 500 ký tự"
3. Hiển thị counter: "520/500"
4. Quay lại bước 5

---

## 10. USE CASE: QUẢN LÝ TÀI KHOẢN

### Tên Use Case

Quản lý tài khoản

### Tác nhân chính

User (Người dùng)

### Mục đích

Cho phép user xem và chỉnh sửa thông tin cá nhân

### Điều kiện kích hoạt

- User click vào avatar/icon profile
- User chọn "Tài khoản của tôi"

### Điều kiện tiên quyết

- User đã đăng nhập

### Điều kiện thành công

- Thông tin được hiển thị đầy đủ
- Thay đổi được lưu thành công
- Avatar được cập nhật

### Điều kiện thất bại

- Lỗi upload avatar
- Lỗi cập nhật Firestore

### Luồng sự kiện chính

1. User click vào avatar
2. Hệ thống hiển thị dropdown menu:
   - Tài khoản của tôi
   - Watchlist
   - Từ vựng
   - Lịch sử xem
   - Cài đặt
   - Đăng xuất
3. User chọn "Tài khoản của tôi"
4. Hệ thống hiển thị profile page:
   - Avatar (có thể click để đổi)
   - Display name
   - Email (read-only)
   - Member since
   - Statistics (số phim đã xem, số từ đã học)
5. User click "Chỉnh sửa"
6. Các field chuyển sang edit mode
7. User thay đổi thông tin
8. User click "Lưu"
9. Hệ thống validate dữ liệu
10. Hệ thống cập nhật Firestore
11. Hiển thị "Đã cập nhật thông tin"

### Luồng sự kiện thay thế

**LSK 4a: User muốn đổi avatar**

1. User click vào avatar
2. Hệ thống mở file picker
3. User chọn ảnh từ máy
4. Hệ thống crop/resize ảnh
5. User xác nhận
6. Hệ thống upload lên Firebase Storage
7. Cập nhật photoURL trong Firestore
8. Avatar mới được hiển thị

**LSK 5a: User muốn đổi mật khẩu**

1. User click "Đổi mật khẩu"
2. Hệ thống hiển thị form:
   - Mật khẩu hiện tại
   - Mật khẩu mới
   - Xác nhận mật khẩu mới
3. User nhập thông tin
4. Hệ thống validate
5. Gọi Firebase updatePassword()
6. Hiển thị "Đã đổi mật khẩu"

### Luồng sự kiện ngoại lệ

**LSK 9a: Validation lỗi**

1. Display name trống hoặc quá dài
2. Hiển thị error message
3. Quay lại bước 7

**LSK 10a: Lỗi cập nhật**

1. Firestore báo lỗi
2. Hiển thị "Không thể cập nhật. Thử lại"
3. Dữ liệu không thay đổi

---

## 11. USE CASE: QUẢN LÝ PHIM (ADMIN)

### Tên Use Case

Quản lý phim

### Tác nhân chính

Admin (Quản trị viên)

### Mục đích

Cho phép admin thêm, sửa, xóa phim trong hệ thống

### Điều kiện kích hoạt

- Admin đăng nhập với quyền admin
- Admin vào trang Admin Panel

### Điều kiện tiên quyết

- Admin có role = "admin" trong Firestore
- Admin đã đăng nhập

### Điều kiện thành công

- Phim được thêm/sửa/xóa thành công
- Files được upload lên Storage
- Dữ liệu được lưu vào Firestore

### Điều kiện thất bại

- Không có quyền admin
- Dữ liệu không hợp lệ
- Lỗi upload files

### Luồng sự kiện chính

**Thêm phim mới:**

1. Admin click "Thêm phim"
2. Hệ thống hiển thị form:
   - Title\*
   - Description\*
   - Year\*
   - Duration (minutes)\*
   - Level\* (select: Beginner/Intermediate/Advanced)
   - Genres\* (multi-select)
   - Cast (array)
   - Director
   - Upload Poster\*
   - Upload Backdrop\*
   - Upload Video\*
   - Upload Subtitles (EN, VI)\*
3. Admin điền thông tin
4. Admin upload các files
5. Admin click "Lưu"
6. Hệ thống validate tất cả fields
7. Hệ thống upload files lên Firebase Storage:
   - /movies/{movieId}/video.mp4
   - /movies/{movieId}/poster.jpg
   - /movies/{movieId}/backdrop.jpg
   - /movies/{movieId}/subtitles/en.srt
   - /movies/{movieId}/subtitles/vi.srt
8. Hệ thống lấy download URLs
9. Hệ thống tạo document trong Firestore:
   ```
   movies/{movieId}
   {
     title: "The Shawshank Redemption",
     description: "...",
     year: 1994,
     duration: 142,
     level: "intermediate",
     genres: ["Drama", "Crime"],
     cast: ["Tim Robbins", "Morgan Freeman"],
     director: "Frank Darabont",
     posterUrl: "...",
     backdropUrl: "...",
     videoUrl: "...",
     subtitles: {
       en: "...",
       vi: "..."
     },
     rating: 0,
     viewCount: 0,
     createdAt: timestamp,
     updatedAt: timestamp
   }
   ```
10. Hệ thống lưu vào Firestore
11. Hiển thị "Đã thêm phim thành công"
12. Redirect về danh sách phim

### Luồng sự kiện thay thế

**LSK 1a: Sửa phim**

1. Admin chọn phim cần sửa từ danh sách
2. Hệ thống load thông tin phim hiện tại
3. Hiển thị form với dữ liệu đã điền sẵn
4. Admin chỉnh sửa
5. Quay lại bước 5 của luồng chính

**LSK 1b: Xóa phim**

1. Admin click nút "Xóa" trên movie item
2. Hệ thống hiển thị confirmation dialog:
   - "Bạn có chắc muốn xóa phim này?"
   - "Hành động này không thể hoàn tác"
   - Button: "Hủy" và "Xóa"
3. Admin click "Xóa"
4. Hệ thống xóa files từ Storage
5. Hệ thống xóa document từ Firestore
6. Hệ thống xóa comments liên quan
7. Hiển thị "Đã xóa phim"

### Luồng sự kiện ngoại lệ

**LSK 6a: Thiếu thông tin bắt buộc**

1. Admin chưa điền đủ fields \*
2. Hệ thống hiển thị error bên dưới field
3. Highlight fields lỗi màu đỏ
4. Quay lại bước 3

**LSK 7a: Lỗi upload file**

1. File quá lớn (video > 500MB)
2. Format không hợp lệ
3. Hiển thị error "File không hợp lệ"
4. Quay lại bước 4

---

## 12. USE CASE: QUẢN LÝ NGƯỜI DÙNG (ADMIN)

### Tên Use Case

Quản lý người dùng

### Tác nhân chính

Admin (Quản trị viên)

### Mục đích

Cho phép admin xem danh sách user, khóa/mở khóa tài khoản

### Điều kiện kích hoạt

- Admin vào trang "Quản lý người dùng" trong Admin Panel

### Điều kiện tiên quyết

- Admin có quyền quản trị

### Điều kiện thành công

- Danh sách user được hiển thị
- Tài khoản user được khóa/mở khóa thành công

### Điều kiện thất bại

- Lỗi query Firestore
- Không thể cập nhật trạng thái user

### Luồng sự kiện chính

1. Admin click "Quản lý người dùng"
2. Hệ thống query collection "users"
3. Hệ thống hiển thị bảng danh sách user:
   | Avatar | Name | Email | Member Since | Status | Actions |
   |--------|------|-------|--------------|--------|---------|
   | 👤 | John | john@email | 2024-01-15 | Active | [Ban] |
4. Admin có thể:
   - Search user by name/email
   - Sort by date
   - Filter by status (Active/Banned)
5. Admin click "Ban" trên 1 user
6. Hệ thống hiển thị dialog:
   - "Khóa tài khoản John Doe?"
   - Text field: "Lý do (tùy chọn)"
   - Button: "Hủy" và "Khóa"
7. Admin nhập lý do (optional)
8. Admin click "Khóa"
9. Hệ thống cập nhật user document:
   ```
   users/{userId}
   {
     ...
     isBanned: true,
     bannedAt: timestamp,
     bannedReason: "Spam comments",
     bannedBy: adminId
   }
   ```
10. Status chuyển sang "Banned"
11. Hiển thị "Đã khóa tài khoản"

### Luồng sự kiện thay thế

**LSK 5a: Mở khóa tài khoản**

1. Admin click "Unban" trên user bị khóa
2. Hiển thị confirm dialog
3. Admin xác nhận
4. Hệ thống cập nhật:
   ```
   isBanned: false,
   unbannedAt: timestamp,
   unbannedBy: adminId
   ```
5. Status chuyển về "Active"

**LSK 4a: Xem chi tiết hoạt động user**

1. Admin click vào row user
2. Hệ thống hiển thị modal với:
   - Profile info
   - Watch history
   - Comments
   - Vocabulary stats
3. Admin xem thông tin
4. Đóng modal

### Luồng sự kiện ngoại lệ

**LSK 2a: Không có user nào**

1. Collection "users" empty
2. Hiển thị empty state
3. Use case kết thúc

---

**HẾT**

_Tổng cộng: 12 Use Cases chính của hệ thống_
