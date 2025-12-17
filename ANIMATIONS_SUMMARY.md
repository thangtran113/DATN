# 🎨 Animation System - Tổng quan

## ✨ Animations đã được áp dụng

### 🏠 Home Screen (`home_screen.dart`)

✅ **FadeInWidget** - Logo và welcome container fade in mượt mà
✅ **ScaleInAnimation** - Avatar và logo scale từ nhỏ đến lớn với bounce effect
✅ **SlideInFromBottom** - Text elements (Welcome back, username, email) trượt lên từ dưới
✅ **AnimatedButton** - Button "Browse Movies" với press effect

**Thời gian animation:**

- Logo: 200ms delay
- Avatar: 400ms delay
- Welcome text: 600ms delay
- Username: 700ms delay
- Email: 800ms delay
- Browse button: 900ms delay
- Coming soon message: 1100ms delay

---

### 🎬 Movie List Screen (`movie_list_screen.dart`)

✅ **SlideInFromBottom** - Mỗi movie card trượt lên với staggered delay
✅ **AnimatedCard** - Movie cards có hover effect (scale 1.05, elevation tăng)

**Đặc điểm:**

- Staggered animation: 50ms delay giữa mỗi card (chỉ áp dụng cho 10 cards đầu)
- Hover scale: 1.05x
- Hover elevation: 8.0

---

### 📚 Vocabulary List Screen (`vocabulary_list_screen.dart`)

✅ **SlideInFromBottom** - Vocabulary cards trượt lên tuần tự
✅ **AnimatedCard** - Word cards có hover effect

**Đặc điểm:**

- Staggered animation: 30ms delay giữa mỗi card (10 cards đầu)
- Smooth hover interactions
- Mastery level color indicators

---

### 📊 Statistics Screen (`statistics_screen.dart`)

✅ **FadeInWidget** - Overview stat cards fade in
✅ **SlideInFromBottom** - Section titles và content trượt lên tuần tự
✅ **AnimatedCard** - Stat cards với hover effect

**Timeline animation:**

- Overview cards: fade in ngay lập tức
- "Phân Bố Trình Độ" title: 200ms delay
- Distribution chart: 300ms delay
- "Tiến Độ Học Tập" title: 400ms delay
- Progress chart: 500ms delay
- "Thông Tin Chi Tiết" title: 600ms delay
- Insights: 700ms delay

---

### 🎴 Flashcard Screen (`flashcard_screen.dart`)

✅ **FadeInWidget** - Progress bar fade in
✅ **ScaleInAnimation** - Flashcard xuất hiện với scale effect
✅ **SlideInFromBottom** - Action buttons trượt lên

**Timeline:**

- Progress bar: fade in 400ms
- Flashcard: scale in 200ms delay
- Action buttons: slide in 400ms delay

**Tính năng đặc biệt:**

- Flip animation riêng cho flashcard (600ms duration)
- Smooth card flipping với 3D transform

---

## 🎯 Animation Constants (`app_animations.dart`)

### Durations

```dart
- fast: 200ms (quick interactions)
- normal: 300ms (standard transitions)
- slow: 500ms (emphasis animations)
- fadeIn: 400ms
- slideIn: 350ms
- scaleIn: 300ms
- hoverDuration: 200ms
```

### Curves

```dart
- defaultCurve: Curves.easeInOut
- bounceIn: Curves.easeOutBack (for scale animations)
- smoothCurve: Curves.easeInOutCubic
```

### Hover Effects

```dart
- hoverScale: 1.05 (5% scale increase)
- hoverElevation: 8.0
```

---

## 🛠️ Animation Widgets

### 1. **FadeInWidget**

- Simple opacity animation từ 0 → 1
- Có thể config delay và duration
- Dùng cho: Text, containers, images

### 2. **SlideInFromBottom**

- Slide từ bottom lên + fade in
- Offset ban đầu: (0, 0.3)
- Dùng cho: Cards, list items, buttons

### 3. **ScaleInAnimation**

- Scale từ 0.8 → 1.0 + fade in
- Có bounce effect với `easeOutBack` curve
- Dùng cho: Icons, avatars, highlight elements

### 4. **AnimatedCard**

- Hover effect với scale và elevation
- MouseRegion để detect hover
- Dùng cho: Interactive cards, buttons

### 5. **AnimatedButton**

- Press effect scale 0.95 khi tap
- Shadow biến mất khi pressed
- Dùng cho: Action buttons

### 6. **ShimmerLoading**

- Loading placeholder với shimmer effect
- Gradient animation lặp vô hạn
- Duration: 1500ms

---

## 🎨 Design Principles

### Đơn giản & Hiện đại

- ✅ Sử dụng easeInOut curve cho smooth transitions
- ✅ Delay nhỏ giữa các elements (30-100ms)
- ✅ Duration ngắn (200-600ms) để không làm chậm UX
- ✅ Hover effects tinh tế (scale 1.05)

### Thân thiện người dùng

- ✅ Animations không làm phiền (non-intrusive)
- ✅ Có thể skip animations (no forced delays)
- ✅ Smooth và predictable
- ✅ Performance optimized (AnimationController dispose properly)

### Đồng nhất

- ✅ Sử dụng cùng animation constants
- ✅ Consistent timing và curves
- ✅ Reusable animation widgets
- ✅ Same hover behavior across app

---

## 🚫 Ngoại lệ

### Login Screen - KHÔNG có animation

- ✅ Login screen giữ nguyên giao diện hiện tại
- ✅ Không áp dụng bất kỳ animation widgets nào
- Lý do: Theo yêu cầu của người dùng

---

## 📈 Performance

### Optimization

- ✅ Staggered animations chỉ áp dụng cho 10 items đầu
- ✅ AnimationController được dispose đúng cách
- ✅ Sử dụng `const` constructors khi có thể
- ✅ Lazy loading với delay

### Best Practices

```dart
// ✅ Good - Dispose controller
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

// ✅ Good - Check mounted
Future.delayed(widget.delay, () {
  if (mounted) _controller.forward();
});

// ✅ Good - Limit staggered items
delay: Duration(milliseconds: 50 * (index % 10))
```

---

## 🎉 Kết quả

### Trải nghiệm người dùng

1. **Smooth & Polished** - App cảm giác professional hơn
2. **Engaging** - Animations thu hút attention một cách tự nhiên
3. **Modern** - Phù hợp với design trends hiện đại
4. **Not Overwhelming** - Không quá nhiều animations

### Technical Quality

1. **Maintainable** - Reusable animation widgets
2. **Performant** - Optimized với proper disposal
3. **Consistent** - Same patterns across app
4. **Extensible** - Dễ thêm animations mới

---

## 📝 Usage Examples

### Basic Fade In

```dart
FadeInWidget(
  child: Text('Hello'),
  delay: Duration(milliseconds: 200),
  duration: Duration(milliseconds: 400),
)
```

### Slide from Bottom

```dart
SlideInFromBottom(
  delay: Duration(milliseconds: 300),
  child: MyWidget(),
)
```

### Animated Card with Hover

```dart
AnimatedCard(
  onTap: () {},
  color: Colors.grey[900],
  child: MyContent(),
)
```

### Staggered List

```dart
ListView.builder(
  itemBuilder: (context, index) {
    return SlideInFromBottom(
      delay: Duration(milliseconds: 50 * (index % 10)),
      child: MyListItem(),
    );
  },
)
```

---

## ✅ Checklist hoàn thành

- [x] Tạo animation constants và widgets
- [x] Áp dụng cho Home Screen
- [x] Áp dụng cho Movie List Screen
- [x] Áp dụng cho Vocabulary List Screen
- [x] Áp dụng cho Statistics Screen
- [x] Áp dụng cho Flashcard Screen
- [x] Giữ nguyên Login Screen (no animations)
- [x] Test performance
- [x] Documentation

---

Made with ❤️ for a better user experience!
