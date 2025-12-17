# 🌐 Web-Only Setup Guide

## Overview

This project is configured as a **web-only** Flutter application. All mobile and desktop platform code has been removed to optimize for web deployment.

## ✅ What Has Been Configured

### 1. Dependencies Cleaned Up

**Removed packages** (not needed for web):

- ❌ `google_sign_in` - Replaced with Firebase Auth Web
- ❌ `wakelock_plus` - Screen wake lock (mobile-only)
- ❌ `image_picker` - Image picking (mobile-focused)
- ❌ `path_provider` - File system access (mobile-focused)
- ❌ `permission_handler` - Runtime permissions (mobile-only)

**Kept packages** (web-compatible):

- ✅ `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
- ✅ `video_player`, `chewie` - Video playback
- ✅ `provider` - State management
- ✅ `go_router` - Web-friendly routing
- ✅ `file_picker` - Web file upload support
- ✅ `shared_preferences` - Web local storage
- ✅ All UI packages (animations, cached_network_image, etc.)

### 2. Platform Folders

Platform-specific folders are **ignored** in `.gitignore`:

```
/android/
/ios/
/linux/
/macos/
/windows/
```

### 3. Web Configuration

#### `web/index.html`

- ✅ SEO meta tags (description, keywords, Open Graph, Twitter Cards)
- ✅ PWA meta tags (mobile-web-app-capable, theme-color)
- ✅ Custom loading screen with CineChill branding
- ✅ Responsive viewport configuration

#### `web/manifest.json`

- ✅ App name: "CineChill - Learn English Through Movies"
- ✅ Brand colors: #0F0F0F background, #E50914 theme
- ✅ PWA configuration for installability
- ✅ Categories: education, entertainment

## 🚀 Development

### Run in Development Mode

```bash
flutter run -d chrome
```

### Build for Production

```bash
flutter build web --release
```

Output: `build/web/`

### Build with Custom Base URL

```bash
flutter build web --release --base-href /my-app/
```

## 🌍 Browser Compatibility

| Browser | Support | Notes                          |
| ------- | ------- | ------------------------------ |
| Chrome  | ✅ Full | Recommended for development    |
| Firefox | ✅ Full |                                |
| Safari  | ✅ Full | May have minor CSS differences |
| Edge    | ✅ Full | Chromium-based                 |
| Opera   | ✅ Full | Chromium-based                 |

**Minimum versions:**

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## 📦 Deployment Options

### 1. Firebase Hosting (Recommended)

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize hosting
firebase init hosting

# Build and deploy
flutter build web --release
firebase deploy --only hosting
```

### 2. Netlify

1. Connect your GitHub repository
2. Build command: `flutter build web --release`
3. Publish directory: `build/web`

### 3. Vercel

1. Import project from GitHub
2. Framework preset: Other
3. Build command: `flutter build web --release`
4. Output directory: `build/web`

### 4. GitHub Pages

```bash
# Build
flutter build web --release --base-href /your-repo-name/

# Deploy (using gh-pages)
cd build/web
git init
git add .
git commit -m "Deploy"
git remote add origin https://github.com/username/repo.git
git push -f origin main:gh-pages
```

## 🎯 Performance Optimization

### Web-Specific Optimizations

1. **Canvas Kit vs HTML Renderer**

   ```bash
   # HTML renderer (smaller, faster loading)
   flutter build web --web-renderer html

   # Canvas Kit (better performance, larger size)
   flutter build web --web-renderer canvaskit

   # Auto (default, chooses best for device)
   flutter build web --web-renderer auto
   ```

2. **Code Splitting**

   - Enabled by default in Flutter web
   - Reduces initial bundle size

3. **Image Optimization**

   - Use `cached_network_image` for remote images
   - Serve images from CDN (Firebase Storage)
   - Use appropriate image formats (WebP for web)

4. **Lazy Loading**
   - Movies loaded in chunks (pagination)
   - Images loaded on scroll

## 🔧 Troubleshooting

### Issue: File picker warnings

**Problem:** Warnings about file_picker on other platforms

**Solution:** These are just warnings. The package works fine on web. To suppress:

```yaml
# In analysis_options.yaml
analyzer:
  errors:
    missing_required_param: ignore
```

### Issue: Video player not working

**Problem:** Videos not playing in browser

**Solution:**

- Ensure videos are in web-compatible format (MP4, H.264)
- Use HTTPS for video URLs
- Check CORS headers on video server

### Issue: Slow initial load

**Problem:** App takes long to load first time

**Solution:**

1. Use `--web-renderer html` for faster load
2. Optimize assets (compress images)
3. Enable CDN caching
4. Use tree-shaking: `flutter build web --tree-shake-icons`

## 📊 Web Analytics

Firebase Analytics is included:

```dart
FirebaseAnalytics analytics = FirebaseAnalytics.instance;
await analytics.logEvent(name: 'page_view', parameters: {
  'page_name': 'movies',
});
```

## 🔒 Security

### Web-Specific Security

1. **Firebase Security Rules**

   - Configured in `firestore.rules`
   - Validates auth on server side

2. **CORS Configuration**

   - Firebase handles CORS automatically
   - For custom backend, configure CORS headers

3. **Environment Variables**
   - Use `--dart-define` for secrets
   - Never commit API keys to repository

```bash
flutter build web --release \
  --dart-define=API_KEY=your_key \
  --dart-define=AUTH_DOMAIN=your_domain
```

## 📝 Best Practices

1. ✅ Always test on multiple browsers
2. ✅ Use responsive breakpoints (mobile/tablet/desktop)
3. ✅ Optimize images (WebP, compression)
4. ✅ Enable PWA features (offline mode, install prompt)
5. ✅ Use web-safe fonts (Google Fonts CDN)
6. ✅ Implement lazy loading for content
7. ✅ Add loading states and skeletons
8. ✅ Test on slow 3G connections
9. ✅ Monitor Core Web Vitals (LCP, FID, CLS)
10. ✅ Use Firebase Performance Monitoring

## 🎨 Responsive Design

Current breakpoints:

```dart
// Mobile: < 600px → 2 columns
// Tablet: 600-900px → 3-4 columns
// Desktop: > 900px → 5 columns

final isMobile = MediaQuery.of(context).size.width < 600;
final isTablet = MediaQuery.of(context).size.width < 900;
```

## 📚 Additional Resources

- [Flutter Web Documentation](https://docs.flutter.dev/platform-integration/web)
- [Firebase Hosting Guide](https://firebase.google.com/docs/hosting)
- [Web Performance Best Practices](https://web.dev/performance/)
- [PWA Documentation](https://web.dev/progressive-web-apps/)

---

**Last Updated:** October 24, 2025
