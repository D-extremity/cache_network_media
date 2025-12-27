# Cache Network Media

**The ultimate Flutter plugin for caching network images, SVGs, and Lottie animations with persistent disk storage and offline support.**

[![pub package](https://img.shields.io/pub/v/cache_network_media.svg)](https://pub.dev/packages/cache_network_media)
[![GitHub](https://img.shields.io/github/license/D-extremity/cache_network_media)](https://github.com/D-extremity/cache_network_media/blob/main/LICENSE)
[![CI](https://github.com/D-extremity/cache_network_media/actions/workflows/ci.yml/badge.svg)](https://github.com/D-extremity/cache_network_media/actions/workflows/ci.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.3.0+-blue.svg)](https://flutter.dev)

---

## Why Cache Network Media?

Tired of your app downloading the same images repeatedly? Want seamless offline support for your media assets? **Cache Network Media** provides a unified, efficient solution for caching all your network media in Flutter.

### ✨ Key Benefits

| Benefit | Description |
|---------|-------------|
| 🚀 **Faster Load Times** | Media loads instantly from local cache after first download |
| 📴 **Offline Support** | Display cached media even without internet connection |
| 💾 **Reduced Bandwidth** | Download once, use forever - saves data for your users |
| 🎯 **Unified API** | One widget for images, SVGs, and Lottie - consistent syntax |
| 📁 **Custom Cache Directory** | Full control over where your cached files are stored |
| 🔧 **Zero Configuration** | Works out of the box with sensible defaults |
| 📱 **Cross-Platform** | Android, iOS with native platform channel support |

---

## Feature Comparison

### Supported Media Types

| Media Type | Supported | Caching Method | Use Case |
|------------|:---------:|----------------|----------|
| PNG | ✅ | Binary | Photos, screenshots, graphics |
| JPG/JPEG | ✅ | Binary | Photos, compressed images |
| WebP | ✅ | Binary | Modern web images, animations |
| GIF | ✅ | Binary | Animated images |
| BMP | ✅ | Binary | Bitmap images |
| SVG | ✅ | Binary | Vector icons, logos, illustrations |
| Lottie JSON | ✅ | JSON File | Animations, micro-interactions |

### Feature Matrix

| Feature | cache_network_media | Others |
|---------|:-------------------:|:------:|
| Image Caching | ✅ | ✅ |
| SVG Support | ✅ | ❌ |
| Lottie Support | ✅ | ❌ |
| Custom Cache Directory | ✅ | ❌ |
| Offline Support | ✅ | ⚠️ |
| Tap Gesture Support | ✅ | ❌ |
| Unified API | ✅ | ❌ |
| File-based Lottie Cache | ✅ | ❌ |
| Platform Channel Support | ✅ | ⚠️ |
| Privacy Manifest (iOS) | ✅ | ❌ |
| Swift Package Manager | ✅ | ⚠️ |

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  cache_network_media: ^0.0.3
```

Then run:

```bash
flutter pub get
```

---

## Quick Start

### Cache Network Images

```dart
CacheNetworkMediaWidget.img(
  url: 'https://example.com/image.png',
  width: 200,
  height: 200,
  fit: BoxFit.cover,
  placeholder: CircularProgressIndicator(),
  onTap: () => print('Image tapped!'),
)
```

### Cache SVG Graphics

```dart
CacheNetworkMediaWidget.svg(
  url: 'https://example.com/icon.svg',
  width: 100,
  height: 100,
  color: Colors.blue,
  onTap: () => print('SVG tapped!'),
)
```

### Cache Lottie Animations

```dart
CacheNetworkMediaWidget.lottie(
  url: 'https://example.com/animation.json',
  width: 300,
  height: 300,
  repeat: true,
  animate: true,
  onTap: () => print('Animation tapped!'),
)
```

---

## Advanced Usage

### Custom Cache Directory

Take full control over where your cached files are stored. This is useful for:
- **Organizing cached files** by feature or user
- **Managing cache size** by clearing specific directories
- **Sharing cache** between different parts of your app
- **Debugging** by easily locating cached files

```dart
import 'dart:io';

// Use a custom directory for caching
final customDir = Directory('/path/to/your/cache');

CacheNetworkMediaWidget.img(
  url: 'https://example.com/image.png',
  cacheDirectory: customDir,
)
```

### Error Handling

Handle network failures gracefully:

```dart
CacheNetworkMediaWidget.img(
  url: 'https://example.com/image.png',
  placeholder: CircularProgressIndicator(),
  errorBuilder: (context, error, stackTrace) {
    return Column(
      children: [
        Icon(Icons.error, color: Colors.red),
        Text('Failed to load image'),
      ],
    );
  },
)
```

### Image with Color Blending

```dart
CacheNetworkMediaWidget.img(
  url: 'https://example.com/image.png',
  color: Colors.blue,
  colorBlendMode: BlendMode.multiply,
  filterQuality: FilterQuality.high,
)
```

### SVG with Theme Support

```dart
CacheNetworkMediaWidget.svg(
  url: 'https://example.com/icon.svg',
  colorFilter: ColorFilter.mode(Colors.red, BlendMode.srcIn),
  theme: SvgTheme(currentColor: Colors.blue),
  semanticsLabel: 'App logo',
)
```

### Lottie with Animation Control

```dart
CacheNetworkMediaWidget.lottie(
  url: 'https://example.com/animation.json',
  repeat: false,           // Play once
  reverse: true,           // Play in reverse
  animate: true,           // Auto-start
  frameRate: 60.0,         // Custom FPS
  addRepaintBoundary: true, // Performance optimization
)
```

---

## API Reference

### Common Parameters (All Media Types)

| Parameter | Type | Description |
|-----------|------|-------------|
| `url` | `String` | **Required.** The network URL of the media |
| `cacheDirectory` | `Directory?` | Custom directory for caching. Uses platform default if null |
| `width` | `double?` | Width of the widget |
| `height` | `double?` | Height of the widget |
| `fit` | `BoxFit?` | How to inscribe the media into the allocated space |
| `alignment` | `AlignmentGeometry` | How to align the media within its bounds |
| `placeholder` | `Widget?` | Widget shown while loading |
| `errorBuilder` | `Function?` | Builder for error widget |
| `onTap` | `VoidCallback?` | Callback when widget is tapped |

### Image-Specific Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `color` | `Color?` | null | Color to blend with image |
| `colorBlendMode` | `BlendMode?` | null | Blend mode for color |
| `filterQuality` | `FilterQuality` | medium | Quality of image sampling |
| `repeat` | `ImageRepeat` | noRepeat | How to paint uncovered portions |
| `semanticLabel` | `String?` | null | Accessibility label |

### SVG-Specific Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `color` | `Color?` | null | Simple color tinting |
| `colorFilter` | `ColorFilter?` | null | Advanced color filtering |
| `theme` | `SvgTheme?` | null | SVG theme for styling |
| `clipBehavior` | `Clip` | hardEdge | How to clip content |

### Lottie-Specific Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `repeat` | `bool` | true | Loop the animation |
| `reverse` | `bool` | false | Play in reverse |
| `animate` | `bool` | true | Start immediately |
| `frameRate` | `double?` | null | Custom FPS |
| `delegates` | `LottieDelegates?` | null | Custom delegates |

---

## How Caching Works

```
┌─────────────────────────────────────────────────────────────┐
│                    Cache Flow Diagram                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Request URL ──► Check Cache ──► Cache Hit? ──► Yes ──►   │
│        │                              │          Return     │
│        │                              │          Cached     │
│        │                              ▼                     │
│        │                             No                     │
│        │                              │                     │
│        │                              ▼                     │
│        │                      Download from                 │
│        │                         Network                    │
│        │                              │                     │
│        │                              ▼                     │
│        │                      Save to Cache                 │
│        │                              │                     │
│        │                              ▼                     │
│        └─────────────────────► Return Media                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Cache Storage

| Media Type | Storage Format | Location |
|------------|---------------|----------|
| Images | `.cache_image` binary | `cache_network_media/` |
| SVG | `.cache_image` binary | `cache_network_media/` |
| Lottie | `.json` file | `cache_network_media/lottie/` |

---

## Platform Support

| Platform | Status | Notes |
|----------|:------:|-------|
| Android | ✅ | Full support with method channels |
| iOS | ✅ | Swift Package Manager + Privacy Manifest |
| Web | 🚧 | Coming soon |
| macOS | 🚧 | Coming soon |
| Windows | 🚧 | Coming soon |
| Linux | 🚧 | Coming soon |

---

## Performance Tips

1. **Use appropriate image sizes** - Don't load 4K images for thumbnails
2. **Leverage custom cache directories** - Organize cache by feature for easier management
3. **Set dimensions when known** - Provide `width` and `height` to avoid layout shifts
4. **Use `addRepaintBoundary`** - Enabled by default for Lottie, improves performance
5. **Handle errors gracefully** - Always provide an `errorBuilder` for production apps

---

## Migration Guide

### From cached_network_image

```dart
// Before (cached_network_image)
CachedNetworkImage(
  imageUrl: 'https://example.com/image.png',
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)

// After (cache_network_media)
CacheNetworkMediaWidget.img(
  url: 'https://example.com/image.png',
  placeholder: CircularProgressIndicator(),
  errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
)
```

---

## Documentation

- [API Reference](https://pub.dev/documentation/cache_network_media/latest/)
- [Architecture Details](ARCHITECTURE.md)
- [Contributing Guidelines](CONTRIBUTING.md)
- [Changelog](CHANGELOG.md)

---

## Contributing

We welcome contributions! Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting a PR.

```bash
# Clone the repository
git clone https://github.com/D-extremity/cache_network_media.git

# Install dependencies
flutter pub get

# Run tests
flutter test

# Check formatting
dart format --set-exit-if-changed .

# Run analyzer
flutter analyze
```

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

## Author

Created with ❤️ by **[@D-extremity](https://github.com/D-extremity)**

---

## Support

If this package helped you, please:
- ⭐ Star the [GitHub repository](https://github.com/D-extremity/cache_network_media)
- 👍 Like on [pub.dev](https://pub.dev/packages/cache_network_media)
- 🐛 Report issues on [GitHub Issues](https://github.com/D-extremity/cache_network_media/issues)

---

<p align="center">
  <b>Cache Network Media</b> - Making network media caching simple since 2025
</p>
