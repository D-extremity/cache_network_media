# Project Architecture

*A technical deep-dive for developers who actually care about how things work.*

## Directory Structure

The classic "where is everything" guide:

```
cache_network_media/
│
├── lib/
│   ├── cache_network_media.dart          # Your entry point (the only file you import)
│   │
│   └── src/                               # Implementation details you shouldn't care about
│       ├── core/                          # Core business logic
│       │   ├── cache_network_image.dart   # Legacy code (kept for backwards compatibility)
│       │   └── disk_cache_manager.dart    # The actual caching happens here
│       │
│       ├── providers/                     # Media type handlers
│       │   ├── base_media_provider.dart   # Abstract base (because DRY)
│       │   ├── image_media_provider.dart  # Handles boring old images
│       │   ├── svg_media_provider.dart    # Vector graphics handler
│       │   └── lottie_media_provider.dart # Animation handler
│       │
│       ├── widgets/                       # UI layer
│       │   └── cache_network_media_widget.dart  # The widget you actually use
│       │
│       └── platform/                      # Native code interface
│           ├── cache_network_media_platform_interface.dart
│           └── cache_network_media_method_channel.dart
│
├── android/                               # Android-specific platform code
├── example/                               # Working examples (actually tested, unlike some packages)
├── test/                                  # Unit tests (yes, we write tests)
└── docs/                                  # Documentation (you're reading it)
```

## Data Flow Architecture

### Standard Flow (Images & SVG)

The straightforward approach:

```
User calls CacheNetworkMediaWidget.img() or .svg()
    ↓
Widget creates appropriate Provider (Image/SVG)
    ↓
Provider.fetchMedia() checks DiskCacheManager
    ↓
Cache exists? → Return cached Uint8List immediately
    ↓
Cache missing? → Download from network via HTTP
    ↓
Save downloaded data to disk cache
    ↓
Provider.buildWidget() creates Image.memory() or SvgPicture.memory()
    ↓
FutureBuilder handles loading/error/success states
    ↓
Widget rendered (finally)
```

### Optimized Flow (Lottie)

Because we're not amateurs:

```
User calls CacheNetworkMediaWidget.lottie()
    ↓
Widget creates LottieMediaProvider
    ↓
Provider.fetchLottieFile() checks lottie/ subdirectory
    ↓
.json file exists? → Return File reference immediately
    ↓
File missing? → Download JSON from network
    ↓
Save as actual .json file (not binary blob like a barbarian)
    ↓
Provider.buildLottieWidget() uses Lottie.file() (faster than Lottie.memory())
    ↓
FutureBuilder<File> handles states
    ↓
Animation rendered with proper performance
```

## Core Components

### BaseMediaProvider

The parent class doing the heavy lifting:

**Responsibilities:**
- Network downloads (with proper error handling)
- Cache directory initialization
- Cache hit/miss logic
- Debug logging (because debugging blind is painful)

**Key Methods:**
```dart
Future<Uint8List> fetchMedia()           // Download or retrieve from cache
Future<Uint8List> downloadFromNetwork()  // HTTP GET with error handling
Widget buildWidget(...)                   // Abstract - implemented by children
Future<void> clearCache()                 // Cache invalidation
```

### Specialized Providers

Each media type gets its own provider because abstraction is nice but specialization is necessary:

**ImageMediaProvider**
- Handles: PNG, JPG, WebP, GIF, BMP (basically anything Image.memory can handle)
- Returns: `Image.memory()` widget
- Cache: Binary blob with hash-based filename

**SvgMediaProvider**
- Handles: SVG files (the scalable kind)
- Returns: `SvgPicture.memory()` widget
- Special feature: Color filtering and theming support
- Cache: Binary blob (SVG is XML but we store as bytes)

**LottieMediaProvider**
- Handles: Lottie JSON animations
- Returns: `Lottie.file()` widget (note: file, not memory)
- Special feature: Saves as actual .json files for debugging
- Cache: Organized in `lottie/` subdirectory
- Why different? Because `Lottie.file()` is faster than parsing bytes

### DiskCacheManager

The unsung hero doing actual I/O:

**Cache Structure:**
```
<platform_cache_directory>/cache_network_media/
├── 1234567890.cache              # Image
├── 0987654321.cache              # SVG
└── lottie/
    ├── safe_url_hash_1.json      # Lottie animation
    └── safe_url_hash_2.json      # Another animation
```

**Key Operations:**
```dart
Future<Uint8List?> getImage(String key)         // Read from cache
Future<void> putImage(String key, Uint8List)    // Write to cache
```

**Cache Key Strategy:**
- Images/SVG: Hash of URL (collision-resistant, filename-safe)
- Lottie: Sanitized URL (preserves .json extension, human-readable)

### Platform Channel

Because platform-specific code is unavoidable:

**Purpose:** Get native cache directory path
**Method:** `getTempCacheDir()`
**Why needed:** Each platform stores temporary files differently
- Android: Context.getCacheDir()
- iOS: NSTemporaryDirectory()
- Others: System temp directory

## Widget Architecture

### CacheNetworkMediaWidget

The public interface. The only class users should instantiate.

**Design Pattern:** Factory with named constructors

**Why named constructors instead of enum parameter?**
- Type safety at compile time
- Different parameter sets for each type
- Self-documenting code
- No enum pollution
- Cleaner API

**Constructor Flow:**
```dart
CacheNetworkMediaWidget.img(...)
    ↓
Calls private constructor CacheNetworkMediaWidget._()
    ↓
Creates ImageMediaProvider
    ↓
Stores config in _extraParams Map
    ↓
Sets _isLottie flag appropriately
```

**Rendering Logic:**
```dart
build() {
  if (_isLottie) {
    return FutureBuilder<File>(...)      // Lottie uses File
  } else {
    return FutureBuilder<Uint8List>(...)  // Images/SVG use bytes
  }
}
```

## Design Decisions

### Why File-Based Caching for Lottie?

**The Problem:**
Lottie files are JSON. Storing JSON as binary blob, then converting back to JSON for parsing is inefficient.

**The Solution:**
Save as `.json` files directly.

**Benefits:**
1. `Lottie.file()` is faster than `Lottie.memory()`
2. Cached files are human-readable (debugging win)
3. Can manipulate JSON before rendering (future feature)
4. No wasteful byte-to-string-to-json conversion

**Tradeoff:**
Slightly more complex code. Worth it.

### Why Provider Pattern?

**Alternatives considered:**
- Single monolithic class with switch statements (maintainability nightmare)
- Strategy pattern (over-engineering)
- Plugin architecture (unnecessary complexity)

**Why Provider won:**
- Shared logic in base class (DRY principle)
- Media-specific logic isolated (SRP principle)
- Easy to extend (OCP principle)
- Testable in isolation
- Clear separation of concerns

### Why Not Use Existing Packages?

**Short answer:** They didn't do what we wanted.

**Long answer:**
- Most image caching packages don't handle SVG
- None properly handle Lottie with file-based caching
- We wanted unified API for all media types
- Custom cache management requirements
- Learning exercise

## Performance Considerations

### Cache Hit Performance
- **O(1) file lookup** - Hash-based filenames
- **Minimal memory footprint** - Files stay on disk until needed
- **No network calls** - Obviously

### Cache Miss Performance
- **HTTP download** - Can't avoid this
- **Async write** - Non-blocking disk I/O
- **Single download** - No duplicate requests for same URL

### Memory Management
- Images loaded as `Uint8List` (not decoded until needed)
- Lottie uses `File` reference (parsed by Lottie package)
- No in-memory cache (disk is cheaper than RAM)

## Testing Strategy

**Unit Tests:**
- Provider logic (fetchMedia, buildWidget)
- Cache operations (get, put, key generation)
- Platform channel communication

**Widget Tests:**
- Placeholder rendering
- Error state handling
- Successful media display
- Parameter passing

**Integration Tests:**
- Full download and cache cycle
- Offline behavior
- Cache persistence across restarts

## Future Enhancements

Things we might add (or you could contribute):

**Video Caching**
- Similar to Lottie approach
- File-based storage
- Thumbnail generation?

**Audio Caching**
- Straightforward file storage
- Streaming support?

**Advanced Cache Management**
- LRU eviction policy
- Size limits
- TTL (time-to-live)
- Manual cache clearing API

**Network Optimization**
- Resume interrupted downloads
- Progressive loading
- Adaptive quality based on network

**Developer Experience**
- Cache statistics API
- Debug overlay showing cache hits/misses
- Cache warming (preload)

## Common Pitfalls

**Problem:** Cache grows indefinitely  
**Solution:** Currently none. Implement cache eviction. Or don't store cat GIFs.

**Problem:** Same URL different images (CDN cache busting)  
**Solution:** URL is the cache key. Change URL = new cache entry.

**Problem:** HTTPS certificate errors  
**Solution:** Fix your certificates. Or allow bad certs (not recommended).

**Problem:** Large files causing memory issues  
**Solution:** We stream HTTP responses. If your Lottie file is 50MB, you have bigger problems.

## Security Considerations

**HTTP vs HTTPS:**
- Both supported
- HTTPS recommended (obviously)
- Certificate validation enabled by default

**Cache Location:**
- Platform-specific temp directory
- Not accessible to other apps
- Cleared when app uninstalled

**URL Validation:**
- Basic URI parsing
- No sanitization of downloaded content
- Trust your image sources

## Contributing to Architecture

Before proposing architectural changes:
1. Understand current design
2. Identify actual problem (not theoretical)
3. Provide benchmarks if claiming performance improvement
4. Consider backwards compatibility
5. Write comprehensive tests

*Don't refactor for fun. Refactor for purpose.*

---

**Architecture by @D-extremity**

*"Any fool can write code that a computer can understand. Good programmers write code that humans can understand." - Martin Fowler*

*We tried to follow that advice. Mostly succeeded.*
