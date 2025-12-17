# 🎬 HƯỚNG DẪN THÊM SAMPLE MOVIES VÀO FIRESTORE

## Cách 1: Firebase Console (Khuyến nghị - Dễ nhất)

### Bước 1: Mở Firebase Console

```
https://console.firebase.google.com/project/cinechill-dev/firestore
```

### Bước 2: Tạo Collection

1. Click "Start collection" hoặc "Add collection"
2. Collection ID: `movies`
3. Click "Next"

### Bước 3: Thêm Document đầu tiên

**Document ID:** Auto-generate hoặc để trống

**Fields:** Copy từng field dưới đây:

```
title (string): The Shawshank Redemption
description (string): Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency.
posterUrl (string): https://image.tmdb.org/t/p/w500/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg
backdropUrl (string): https://image.tmdb.org/t/p/w1280/kXfqcdQKsToO0OUXHcrrNCHDBzO.jpg
duration (number): 142
level (string): intermediate
genres (array):
  - Drama
  - Crime
languages (array):
  - en
  - vi
rating (number): 9.3
year (number): 1994
cast (array):
  - Tim Robbins
  - Morgan Freeman
  - Bob Gunton
director (string): Frank Darabont
viewCount (number): 0
createdAt (string): 2025-10-23T10:00:00.000Z
updatedAt (string): 2025-10-23T10:00:00.000Z
```

### Bước 4: Thêm thêm movies (Copy-paste nhanh)

#### Movie 2: Forrest Gump (Beginner)

```
title: Forrest Gump
description: The presidencies of Kennedy and Johnson, the Vietnam War, and other historical events unfold from the perspective of an Alabama man with an IQ of 75.
posterUrl: https://image.tmdb.org/t/p/w500/saHP97rTPS5eLmrLQEcANmKrsFl.jpg
backdropUrl: https://image.tmdb.org/t/p/w1280/3h1JZGDhZ8nzxdgvkxha0qBqi05.jpg
duration: 142
level: beginner
genres: [Drama, Romance]
languages: [en, vi]
rating: 8.8
year: 1994
cast: [Tom Hanks, Robin Wright, Gary Sinise]
director: Robert Zemeckis
viewCount: 0
createdAt: 2025-10-23T10:00:00.000Z
updatedAt: 2025-10-23T10:00:00.000Z
```

#### Movie 3: Finding Nemo (Beginner)

```
title: Finding Nemo
description: After his son is captured in the Great Barrier Reef and taken to Sydney, a timid clownfish sets out on a journey to bring him home.
posterUrl: https://image.tmdb.org/t/p/w500/eHuGQ10FUzK1mdOY69wF5pGgEf5.jpg
backdropUrl: https://image.tmdb.org/t/p/w1280/n1y094tVDFATSzkTnFxoGZ1qNsG.jpg
duration: 100
level: beginner
genres: [Animation, Family, Adventure]
languages: [en, vi]
rating: 8.1
year: 2003
cast: [Albert Brooks, Ellen DeGeneres, Alexander Gould]
director: Andrew Stanton
viewCount: 0
createdAt: 2025-10-23T10:00:00.000Z
updatedAt: 2025-10-23T10:00:00.000Z
```

#### Movie 4: Inception (Advanced)

```
title: Inception
description: A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea.
posterUrl: https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg
backdropUrl: https://image.tmdb.org/t/p/w1280/s3TBrRGB1iav7gFOCNx3H31MoES.jpg
duration: 148
level: advanced
genres: [Action, Sci-Fi, Thriller]
languages: [en, vi]
rating: 8.8
year: 2010
cast: [Leonardo DiCaprio, Joseph Gordon-Levitt, Ellen Page]
director: Christopher Nolan
viewCount: 0
createdAt: 2025-10-23T10:00:00.000Z
updatedAt: 2025-10-23T10:00:00.000Z
```

#### Movie 5: The Pursuit of Happyness (Beginner)

```
title: The Pursuit of Happyness
description: A struggling salesman takes custody of his son as he's poised to begin a life-changing professional career.
posterUrl: https://image.tmdb.org/t/p/w500/iB6MikNT9anEZFHT83T7vH1T5rY.jpg
backdropUrl: https://image.tmdb.org/t/p/w1280/j5wkiYFvUWeqCKH1KUEV2DPTfLN.jpg
duration: 117
level: beginner
genres: [Biography, Drama]
languages: [en, vi]
rating: 8.0
year: 2006
cast: [Will Smith, Jaden Smith, Thandiwe Newton]
director: Gabriele Muccino
viewCount: 0
createdAt: 2025-10-23T10:00:00.000Z
updatedAt: 2025-10-23T10:00:00.000Z
```

---

## Cách 2: Import JSON (Nhanh hơn cho nhiều phim)

### Tạo file movies.json:

```json
{
  "movies": [
    {
      "title": "The Shawshank Redemption",
      "description": "Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency.",
      "posterUrl": "https://image.tmdb.org/t/p/w500/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg",
      "backdropUrl": "https://image.tmdb.org/t/p/w1280/kXfqcdQKsToO0OUXHcrrNCHDBzO.jpg",
      "duration": 142,
      "level": "intermediate",
      "genres": ["Drama", "Crime"],
      "languages": ["en", "vi"],
      "rating": 9.3,
      "year": 1994,
      "cast": ["Tim Robbins", "Morgan Freeman", "Bob Gunton"],
      "director": "Frank Darabont",
      "viewCount": 0,
      "createdAt": "2025-10-23T10:00:00.000Z",
      "updatedAt": "2025-10-23T10:00:00.000Z"
    }
  ]
}
```

### Import bằng Firebase CLI:

```bash
firebase firestore:import movies.json --project cinechill-dev
```

---

## Cách 3: Sửa Firestore Rules để cho phép write tạm (Test only)

Nếu bạn muốn chạy seed script từ code, tạm thời sửa rules:

```javascript
// firestore.rules - TEMPORARY ONLY
match /movies/{movieId} {
  allow read, write: if true;  // ← Cho phép ai cũng write (CHỈ ĐỂ TEST)
}
```

Sau đó chạy:

```bash
dart run lib/data/seed_data.dart
```

**⚠️ LƯU Ý:** Nhớ đổi lại thành `allow write: if false;` sau khi seed xong!

---

## Kiểm tra sau khi thêm

1. Reload app (press `r` trong terminal Flutter)
2. Click "Browse Movies" từ Home
3. Bạn sẽ thấy danh sách phim hiển thị

## Video hướng dẫn Firebase Console

Nếu cần, search YouTube: "How to add documents to Firestore console"
