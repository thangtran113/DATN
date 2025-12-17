# HƯỚNG DẪN THÊM VIDEO URL CHO MOVIES

## Cách 1: Thêm qua Firebase Console (Nhanh nhất)

1. Vào Firebase Console: https://console.firebase.google.com
2. Chọn project `cinechill-dev`
3. Vào **Firestore Database**
4. Chọn collection `movies`
5. Click vào một movie document
6. Click **Edit document**
7. Thêm field mới hoặc edit field hiện có:

   - Field: `videoUrl`
   - Type: string
   - Value: `https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4`

8. Click **Update**
9. Lặp lại cho các movies khác

---

## Cách 2: Dùng Script (Tự động cho tất cả movies)

### Bước 1: Cài đặt dependencies

```bash
cd scripts
npm install firebase-admin
```

### Bước 2: Download Service Account Key

1. Vào Firebase Console → Project Settings → Service Accounts
2. Click "Generate new private key"
3. Lưu file vào `scripts/serviceAccountKey.json`

### Bước 3: Update script

Mở `scripts/add_video_urls.js` và uncomment dòng:

```javascript
const serviceAccount = require("./serviceAccountKey.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
```

### Bước 4: Chạy script

```bash
node scripts/add_video_urls.js
```

---

## Sample Video URLs (Free to use)

Các video này là public và miễn phí từ Google:

1. **Big Buck Bunny** (10 phút)

   ```
   https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4
   ```

2. **Elephants Dream** (11 phút)

   ```
   https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4
   ```

3. **Sintel** (15 phút)

   ```
   https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4
   ```

4. **Tears of Steel** (12 phút)

   ```
   https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4
   ```

5. **For Bigger Fun** (1 phút)
   ```
   https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4
   ```

---

## Cách 3: Upload Video Của Bạn lên Firebase Storage

### Bước 1: Vào Firebase Console

1. Chọn **Storage** trong menu bên trái
2. Click **Upload file**
3. Chọn video file (MP4 format recommended)
4. Upload vào folder `movies/`

### Bước 2: Lấy Download URL

1. Click vào file vừa upload
2. Copy **Download URL** (gốc, không phải tokens)
3. Paste URL vào field `videoUrl` của movie

---

## Test Video Player

Sau khi thêm videoUrl:

1. Reload Flutter app
2. Vào movie detail page
3. Click "Watch Now"
4. Video player sẽ load và play video!

---

## Lưu ý:

- ⚠️ Video file lớn sẽ tốn băng thông Firebase
- ⚠️ Free tier Firebase có giới hạn 1GB/day download
- ✅ Dùng sample videos của Google để test trước
- ✅ Sau khi hoàn thiện app mới upload video thật

---

## Next Steps:

Sau khi có videoUrl, bạn sẽ làm:

1. ✅ Video player (done)
2. 🔄 Phụ đề song ngữ (next)
3. 🔄 Dictionary integration
4. 🔄 Vocabulary management
