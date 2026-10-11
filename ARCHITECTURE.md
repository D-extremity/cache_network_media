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
│
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

### Lottie Flow

Lottie uses the same flow as images and SVGs: the JSON is cached as bytes in the
shared disk cache, and `LottieMediaProvider.buildWidget()` renders it with
`Lottie.memory()`. Rendering from the loaded bytes means the animation does not
depend on the cache file still existing after loading (for example, if the
size limit deletes it).

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
- Returns: `Lottie.memory()` widget
- Cache: Same hashed files as images and SVGs

### DiskCacheManager

The unsung hero doing actual I/O:

**Cache Structure:**
```
<application_cache_directory>/cache_network_media/
├── 3f786850e387550fdab836ed7e6dc881de23001b.cache   # any media type
└── 9a0364b9e99bb480dd25e1f0284c8555d3a7c1d4.cache
```

**Key Operations:**
```dart
File fileFor(String key)                        // <sha1(key)>.cache
Future<Uint8List?> getImage(String key)         // Read from cache
Future<void> putImage(String key, Uint8List)    // Write to a .tmp file, then rename
```

**Cache Key Strategy:** images, SVGs and Lottie files all use the SHA-1 hash of the
URL as the file name. It is collision-resistant, stable across Dart versions, and a
fixed 40 characters, however long the URL is.

**In-flight downloads:** `BaseMediaProvider.fetchMedia` keeps a map from cache entry to
the running future, so concurrent requests for one URL share a single download.

### Cache directory

There is no native code. The default directory comes from
`getApplicationCacheDirectory()` (`path_provider`), plus a
`cache_network_media/` subfolder.

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
```

**Rendering Logic:**
```dart
build() {
  return FutureBuilder<Uint8List>(...)  // Images, SVG and Lottie use bytes
}
```

## Design Decisions

### Why Lottie Renders From Memory

Earlier versions saved Lottie files as `.json` in a `lottie/` subfolder and rendered
them with `Lottie.file()`. That caused two problems:

1. The URL was used as the file name, which fails for long URLs.
2. Rendering depended on the file still existing after loading, so the cache
   size limit could delete it before `Lottie.file()` read it.

`Lottie.file()` reads the file into bytes and parses them the same way
`Lottie.memory()` does, so rendering from the bytes already loaded costs nothing
extra and removes the second disk read.

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
- None cache Lottie animations on disk
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
