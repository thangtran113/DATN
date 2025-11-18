# Import Sample Movies to Firestore

## Dữ liệu phim

File `sample_movies.json` chứa 10 phim mẫu với đầy đủ thông tin:

1. **The Shawshank Redemption** (1994) - Drama, Crime - Intermediate
2. **The Dark Knight** (2008) - Action, Crime, Drama - Advanced
3. **Forrest Gump** (1994) - Drama, Romance - Beginner
4. **Inception** (2010) - Action, Sci-Fi, Thriller - Advanced
5. **The Lion King** (1994) - Animation, Adventure, Drama - Beginner
6. **Parasite** (2019) - Drama, Thriller - Intermediate
7. **Interstellar** (2014) - Adventure, Drama, Sci-Fi - Advanced
8. **Spirited Away** (2001) - Animation, Adventure, Fantasy - Intermediate
9. **The Avengers** (2012) - Action, Sci-Fi, Adventure - Intermediate
10. **Toy Story** (1995) - Animation, Adventure, Comedy - Beginner

## Cách 1: Import qua Firebase Console (Khuyến nghị)

1. Mở https://console.firebase.google.com/
2. Chọn project `cinechill-dev`
3. Vào **Firestore Database**
4. Tạo collection mới tên `movies` (nếu chưa có)
5. Thêm từng document thủ công bằng cách copy dữ liệu từ `sample_movies.json`

## Cách 2: Sử dụng Node.js Script

### Bước 1: Tải Service Account Key

1. Vào Firebase Console > Project Settings > Service Accounts
2. Click "Generate new private key"
3. Lưu file JSON vào thư mục root với tên `firebase-service-account.json`
4. **Quan trọng**: Thêm file này vào `.gitignore`

### Bước 2: Cài đặt dependencies

```bash
npm install firebase-admin
```

### Bước 3: Chạy script

```bash
node scripts/import_movies.js
```

## Cách 3: Import trực tiếp qua Firebase CLI

```bash
# Cài đặt Firebase CLI (nếu chưa có)
npm install -g firebase-tools

# Login
firebase login

# Import data
firebase firestore:import ./scripts/ --project cinechill-dev
```

## Cấu trúc dữ liệu mỗi phim

```json
{
  "title": "Tên phim",
  "description": "Mô tả phim",
  "posterUrl": "URL ảnh poster",
  "backdropUrl": "URL ảnh nền",
  "trailerUrl": "URL trailer YouTube",
  "year": 2024,
  "duration": 120,
  "rating": 8.5,
  "genres": ["Action", "Drama"],
  "level": "beginner|intermediate|advanced",
  "director": "Tên đạo diễn",
  "cast": ["Diễn viên 1", "Diễn viên 2"],
  "viewCount": 1000,
  "country": "USA",
  "language": "English",
  "subtitles": ["English", "Vietnamese"],
  "vocabularyCount": 200,
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## Lưu ý

- Tất cả ảnh sử dụng URL từ TMDB (The Movie Database)
- Trailer links đến YouTube
- Dữ liệu đã được phân loại theo level: beginner, intermediate, advanced
- Phù hợp cho mục đích học tiếng Anh qua phim
