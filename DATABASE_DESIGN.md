# THIẾT KẾ CƠ SỞ DỮ LIỆU FIRESTORE

## 📊 COLLECTIONS & DOCUMENTS

### 1. **users** Collection

Lưu trữ thông tin người dùng

```typescript
{
  uid: string,                    // Firebase Auth UID (Document ID)
  email: string,
  displayName: string,
  photoURL: string | null,
  role: "user" | "admin",
  preferences: {
    favoriteGenres: string[],     // ["action", "comedy", "drama"]
    learningLevel: "beginner" | "intermediate" | "advanced",
    subtitleLanguage: "en" | "vi" | "both",
    autoPlayNext: boolean
  },
  statistics: {
    totalWatchTime: number,       // minutes
    moviesWatched: number,
    vocabularyLearned: number,
    loginStreak: number
  },
  createdAt: Timestamp,
  updatedAt: Timestamp,
  lastLoginAt: Timestamp,
  isActive: boolean
}
```

**Indexes:**

- `email` (ascending)
- `createdAt` (descending)

---

### 2. **movies** Collection

Lưu trữ thông tin phim

```typescript
{
  id: string,                     // Document ID
  title: string,
  originalTitle: string,          // Tên gốc
  description: string,
  plot: string,                   // Cốt truyện chi tiết
  genres: string[],               // ["action", "thriller"]
  director: string,
  cast: string[],                 // ["Actor 1", "Actor 2"]
  releaseYear: number,
  duration: number,               // minutes
  language: string,               // "en", "ko", "ja"
  country: string,

  // Media URLs
  videoUrl: string,               // Firebase Storage URL
  thumbnailUrl: string,
  posterUrl: string,
  trailerUrl: string | null,

  // Ratings & Stats
  averageRating: number,          // 0-5
  totalRatings: number,
  viewCount: number,
  commentCount: number,

  // Subtitles
  subtitles: {
    en: string,                   // Storage URL to SRT file
    vi: string
  },

  // Learning metadata
  difficulty: "easy" | "medium" | "hard",
  vocabularyLevel: number,        // 1-10
  commonWords: string[],          // Top 50 từ phổ biến

  // Admin
  uploadedBy: string,             // Admin UID
  isPublished: boolean,
  isFeatured: boolean,
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

**Indexes:**

- `genres` (array-contains)
- `releaseYear` (descending)
- `averageRating` (descending)
- `viewCount` (descending)
- `createdAt` (descending)
- `isPublished` (ascending)

**Composite Indexes:**

- `isPublished` (ascending) + `averageRating` (descending)
- `isPublished` (ascending) + `viewCount` (descending)
- `genres` (array-contains) + `averageRating` (descending)

---

### 3. **subtitles** Collection (Alternative approach)

Lưu trữ phụ đề chi tiết (nếu không dùng SRT file)

```typescript
{
  id: string,                     // Document ID
  movieId: string,
  language: "en" | "vi",

  lines: [
    {
      index: number,
      startTime: number,          // milliseconds
      endTime: number,
      text: string,
      translation: string | null  // Nếu có
    }
  ],

  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

**Indexes:**

- `movieId` + `language`

---

### 4. **comments** Collection

Bình luận và đánh giá phim

```typescript
{
  id: string,                     // Document ID
  movieId: string,
  userId: string,
  userDisplayName: string,        // Denormalized
  userPhotoURL: string | null,    // Denormalized

  content: string,
  rating: number,                 // 1-5 stars

  // Social
  likes: number,
  dislikes: number,
  replyCount: number,

  // Status
  isEdited: boolean,
  isReported: boolean,
  isHidden: boolean,

  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

**Indexes:**

- `movieId` + `createdAt` (descending)
- `userId` + `createdAt` (descending)

**Subcollection: replies**

```typescript
comments/{commentId}/replies/{replyId}
{
  id: string,
  userId: string,
  userDisplayName: string,
  content: string,
  likes: number,
  createdAt: Timestamp
}
```

---

### 5. **vocabulary** Collection

Từ vựng đã lưu của người dùng

```typescript
{
  id: string,                     // Document ID
  userId: string,

  // Word info
  word: string,
  meaning: string,
  pronunciation: string,          // IPA
  partOfSpeech: string,           // "noun", "verb", "adjective"
  examples: string[],
  synonyms: string[],

  // Context
  movieId: string,
  movieTitle: string,             // Denormalized
  sentence: string,               // Câu trong phim
  timestamp: number,              // Video timestamp

  // Learning
  mastery: "new" | "learning" | "mastered",
  reviewCount: number,
  lastReviewedAt: Timestamp | null,
  nextReviewAt: Timestamp | null,

  createdAt: Timestamp
}
```

**Indexes:**

- `userId` + `createdAt` (descending)
- `userId` + `mastery`
- `userId` + `nextReviewAt` (ascending)
- `word` + `userId`

---

### 6. **history** Collection

Lịch sử xem phim

```typescript
{
  id: string,                     // Document ID: userId_movieId
  userId: string,
  movieId: string,
  movieTitle: string,             // Denormalized
  movieThumbnail: string,         // Denormalized

  // Progress
  progress: number,               // seconds
  duration: number,               // Total duration
  progressPercentage: number,     // 0-100
  isCompleted: boolean,

  // Stats
  watchCount: number,
  totalWatchTime: number,         // minutes

  // Timestamps
  firstWatchedAt: Timestamp,
  lastWatchedAt: Timestamp,
  updatedAt: Timestamp
}
```

**Indexes:**

- `userId` + `lastWatchedAt` (descending)
- `userId` + `isCompleted`

---

### 7. **watchlist** Collection

Danh sách phim yêu thích

```typescript
{
  id: string,                     // Document ID: userId_movieId
  userId: string,
  movieId: string,
  movieTitle: string,             // Denormalized
  movieThumbnail: string,         // Denormalized
  movieGenres: string[],          // Denormalized

  addedAt: Timestamp
}
```

**Indexes:**

- `userId` + `addedAt` (descending)

---

### 8. **loops** Collection

Đoạn phim được loop để học

```typescript
{
  id: string,
  userId: string,
  movieId: string,

  startTime: number,              // seconds
  endTime: number,
  subtitleText: string,
  translation: string,

  // Stats
  loopCount: number,
  lastPlayedAt: Timestamp,

  createdAt: Timestamp
}
```

**Indexes:**

- `userId` + `movieId`
- `userId` + `lastPlayedAt` (descending)

---

### 9. **notifications** Collection

Thông báo cho người dùng

```typescript
{
  id: string,
  userId: string,

  type: "comment" | "reply" | "new_movie" | "achievement" | "reminder",
  title: string,
  message: string,
  data: any,                      // Extra data

  isRead: boolean,

  createdAt: Timestamp
}
```

**Indexes:**

- `userId` + `isRead` + `createdAt` (descending)

---

### 10. **analytics** Collection

Thống kê hệ thống (cho admin)

```typescript
{
  id: string,                     // Format: YYYY-MM-DD
  date: Timestamp,

  users: {
    totalUsers: number,
    activeUsers: number,
    newUsers: number
  },

  movies: {
    totalMovies: number,
    totalViews: number,
    totalWatchTime: number
  },

  engagement: {
    totalComments: number,
    totalRatings: number,
    totalVocabulary: number
  }
}
```

---

## 🔒 SECURITY RULES

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    function isAdmin() {
      return isAuthenticated() &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "admin";
    }

    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isOwner(userId);
      allow update: if isOwner(userId) || isAdmin();
      allow delete: if isAdmin();
    }

    // Movies collection
    match /movies/{movieId} {
      allow read: if true;  // Public read
      allow write: if isAdmin();
    }

    // Comments collection
    match /comments/{commentId} {
      allow read: if true;  // Public read
      allow create: if isAuthenticated();
      allow update: if isOwner(resource.data.userId) || isAdmin();
      allow delete: if isOwner(resource.data.userId) || isAdmin();

      // Replies subcollection
      match /replies/{replyId} {
        allow read: if true;
        allow create: if isAuthenticated();
        allow update: if isOwner(resource.data.userId);
        allow delete: if isOwner(resource.data.userId) || isAdmin();
      }
    }

    // Vocabulary collection
    match /vocabulary/{vocabId} {
      allow read: if isOwner(resource.data.userId);
      allow create: if isAuthenticated() && isOwner(request.resource.data.userId);
      allow update, delete: if isOwner(resource.data.userId);
    }

    // History collection
    match /history/{historyId} {
      allow read: if isOwner(resource.data.userId);
      allow write: if isAuthenticated() && isOwner(request.resource.data.userId);
    }

    // Watchlist collection
    match /watchlist/{watchlistId} {
      allow read: if isOwner(resource.data.userId);
      allow write: if isAuthenticated() && isOwner(request.resource.data.userId);
    }

    // Loops collection
    match /loops/{loopId} {
      allow read: if isOwner(resource.data.userId);
      allow write: if isAuthenticated() && isOwner(request.resource.data.userId);
    }

    // Notifications collection
    match /notifications/{notificationId} {
      allow read: if isOwner(resource.data.userId);
      allow write: if isAdmin();
    }

    // Analytics collection
    match /analytics/{analyticsId} {
      allow read: if isAdmin();
      allow write: if false;  // Only via Cloud Functions
    }
  }
}
```

---

## 📈 QUERY EXAMPLES

### Lấy phim phổ biến

```dart
FirebaseFirestore.instance
  .collection('movies')
  .where('isPublished', isEqualTo: true)
  .orderBy('viewCount', descending: true)
  .limit(10)
  .get();
```

### Lấy phim theo thể loại

```dart
FirebaseFirestore.instance
  .collection('movies')
  .where('genres', arrayContains: 'action')
  .orderBy('averageRating', descending: true)
  .get();
```

### Lấy lịch sử xem của user

```dart
FirebaseFirestore.instance
  .collection('history')
  .where('userId', isEqualTo: currentUserId)
  .orderBy('lastWatchedAt', descending: true)
  .limit(20)
  .get();
```

### Lấy từ vựng cần ôn tập

```dart
FirebaseFirestore.instance
  .collection('vocabulary')
  .where('userId', isEqualTo: currentUserId)
  .where('nextReviewAt', isLessThanOrEqualTo: Timestamp.now())
  .get();
```

### Lấy comments của phim (với pagination)

```dart
FirebaseFirestore.instance
  .collection('comments')
  .where('movieId', isEqualTo: movieId)
  .orderBy('createdAt', descending: true)
  .limit(20)
  .get();
```

---

## 🔄 DATA MIGRATION STRATEGY

### Phase 1: Initial Setup

1. Create collections structure
2. Set up security rules
3. Create composite indexes

### Phase 2: Seed Data

1. Upload sample movies with metadata
2. Upload subtitles
3. Create test users

### Phase 3: Production

1. Implement data validation
2. Set up backup strategy
3. Monitor query performance

---

## 💡 OPTIMIZATION TIPS

1. **Denormalization**: Lưu movieTitle, thumbnail trong history/watchlist để giảm queries
2. **Pagination**: Implement cursor-based pagination cho danh sách dài
3. **Caching**: Cache movie list, popular movies ở client
4. **Aggregation**: Dùng Cloud Functions để update counters (viewCount, commentCount)
5. **Batch Operations**: Use batch writes khi update nhiều documents
6. **Offline Support**: Enable Firestore offline persistence

---

## 📊 STORAGE STRUCTURE (Firebase Storage)

```
/movies/
  /{movieId}/
    video.mp4
    thumbnail.jpg
    poster.jpg
    subtitles/
      en.srt
      vi.srt

/users/
  /{userId}/
    avatar.jpg
```

---

**Note**: Database design này có thể điều chỉnh dựa trên yêu cầu thực tế và testing performance.
