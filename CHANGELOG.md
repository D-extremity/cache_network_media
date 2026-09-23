# Changelog

## 1.1.0

### New Features
* **`CacheNetworkMediaImageProvider`** - A standard `ImageProvider` backed by the same disk cache as `CacheNetworkMediaWidget.img`
  - Works with `Image`, `CircleAvatar`, `DecorationImage`, `Ink.image` and `precacheImage`
  - Decoded images go through Flutter's `ImageCache`
  - Compatible with `ResizeImage` for decoding at a smaller size
  - Failed loads are evicted from the `ImageCache` so they can be retried
* **Memory-safe decoding** - `memCacheWidth` and `memCacheHeight` on `CacheNetworkMediaWidget.img` decode images at the displayed size
* **Cache control** - Applies to images, SVGs and Lottie files
  - `CacheNetworkMedia.maxAge`: expired files are downloaded again; if that fails (e.g. offline), the expired copy is shown
  - `CacheNetworkMedia.maxCacheSizeBytes`: deletes least recently used files once the limit is exceeded
  - `CacheNetworkMedia.clear()`, `evict(url)` and `prefetch(url)`
  - Both settings default to `null`, so existing behavior is unchanged

### Bug Fixes
* **No reload on rebuild** - The widget loads once per URL. Parent rebuilds no longer read the disk again, decode again or flash the placeholder (including in lazy loading mode)
* **`AlignmentDirectional`** - No longer crashes SVG and Lottie widgets; it is resolved using the ambient text direction
* **Interrupted writes** - Cache files are written to a temporary file and renamed, so a killed app no longer leaves a truncated entry
* **Long Lottie URLs** - Lottie files now share the hashed cache used for images and SVGs instead of using the URL as the filename, which failed for URLs longer than the file system allows
* **Cache clearing** - `clearCache()` now deletes the file the cache actually writes
* **Corrupt cache entries** - Image bytes that cannot be decoded (e.g. an HTML error page served with status 200) are removed from disk instead of failing on every load

### Deprecations
* `loadingBuilder` on `CacheNetworkMediaWidget.img` was never used and is now deprecated. Use `placeholder` instead. It will be removed in 2.0.0.

### Notes
* **iOS cache location** - The cache moved from `tmp/`, which iOS can clear at any time, to `Library/Caches`, which persists between launches. Media cached by 1.0.x is downloaded once more.
* **Android cache location** - Falls back to the internal cache directory when external storage is unavailable, instead of failing every load.
* Lottie files cached by 1.0.x in the `lottie/` subfolder are no longer used and are downloaded once more. They live in the temporary directory, which the OS reclaims.

### Chores
* Removed committed Gradle build output and added `android/.gradle/` and `android/build/` to `.gitignore`

---

## 1.0.5

### Bug Fixes
* **Lazy Loading** - Fixed visibility detection issue in lazy loading functionality

---

## 1.0.4

### New Features
* **True Lazy Loading** - Added `lazyLoading` parameter with viewport-based visibility detection
  - Uses `visibility_detector` package for accurate viewport tracking
  - Only loads media when widgets are actually visible on screen
  - Works with both vertical and horizontal scrolling
  - Significantly reduces bandwidth and memory usage in long lists/grids
  - Starts loading when `visibleFraction > 0` (even partially visible)

### Dependencies
* **visibility_detector: ^0.4.0+2** - Added for true lazy loading support

### Improvements
* **StatefulWidget Migration** - Converted `CacheNetworkMediaWidget` from StatelessWidget to StatefulWidget
* **Comprehensive Documentation** - Updated docs to explain true lazy loading benefits and usage

### Breaking Changes
* None - Lazy loading is opt-in via the `lazyLoading` parameter (defaults to `false`)

---

## 0.0.3

### New Features
* **onTap callback** - Added tap gesture support to all media widgets (images, SVG, Lottie)
* **GitHub Actions CI** - Automated testing, linting, and format checking on every push/PR

### Improvements
* **Code Quality** - Converted all block comments to Dart doc comments (`///`)
* **Removed Unused Imports** - Cleaned up unnecessary `dart:typed_data` imports
* **Better Linting** - Fixed all `flutter analyze` warnings and info messages

### Breaking Changes
* None

---

## 0.0.2

* Added Swift Package Manager support for iOS
* Added privacy manifest (PrivacyInfo.xcprivacy)

## 0.0.1

* Initial release
* Support for caching network images, SVG graphics, and Lottie animations
* Automatic disk caching with offline support
* Customizable placeholders and error widgets
