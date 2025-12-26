# Cache Network Media

**Because reinventing the wheel is overrated. Efficiently cache network images, SVG graphics, and Lottie animations in Flutter.**

[![pub package](https://img.shields.io/pub/v/cache_network_media.svg)](https://pub.dev/packages/cache_network_media)
[![GitHub](https://img.shields.io/github/license/D-extremity/cache_network_media)](https://github.com/D-extremity/cache_network_media/blob/main/LICENSE)

## Features

Stop downloading the same image 47 times per session. This package provides:

- **Image Caching** - PNG, JPG, WebP, GIF. Yes, even those animated cat GIFs.
- **SVG Support** - Vector graphics that actually scale without pixelation nightmares.
- **Lottie Animations** - Because sometimes static images just don't cut it.
- **Disk Caching** - Persistent storage that survives app restarts (unlike your user's patience).
- **Offline Support** - Display cached media when the internet decides to take a vacation.
- **Optimized Performance** - File-based caching for Lottie because we actually care about performance.
- **Clean API** - Named constructors that make sense. Revolutionary concept, we know.

## Installation

Add this to your `pubspec.yaml` (you know the drill):

```yaml
dependencies:
  cache_network_media: ^0.0.1
```

Then run the command you've run 10,000 times:
```bash
flutter pub get
```

## Usage

### Caching Images

The most common use case. Probably what you're here for.

```dart
CacheNetworkMediaWidget.img(
  url: 'https://example.com/image.png',
  width: 200,
  height: 200,
  fit: BoxFit.cover,
  placeholder: CircularProgressIndicator(),
)
```

### SVG Graphics

For when you need crisp graphics at any size.

```dart
CacheNetworkMediaWidget.svg(
  url: 'https://example.com/icon.svg',
  width: 100,
  height: 100,
  color: Colors.blue,
)
```

### Lottie Animations

Because your designer insisted on that fancy loading animation.

```dart
CacheNetworkMediaWidget.lottie(
  url: 'https://example.com/animation.json',
  width: 300,
  height: 300,
  repeat: true,
  animate: true,
)
```

## Advanced Features

### Custom Cache Directory

Want to control where we store your precious cached files? Sure.

```dart
CacheNetworkMediaWidget.img(
  url: 'https://example.com/image.png',
  cacheDirectory: Directory('/your/custom/path'),
)
```

### Error Handling

When things inevitably go wrong (network fails, server returns a 404, etc.):

```dart
CacheNetworkMediaWidget.img(
  url: 'https://example.com/image.png',
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.broken_image);
  },
)
```

## How It Works

Simple: Download once, cache forever (or until you clear the cache). Each media type gets cached appropriately:

- **Images & SVG**: Binary cache files
- **Lottie**: JSON files (because parsing bytes into JSON just to parse them again is inefficient)

Cache hits are logged. Cache misses trigger downloads. It's not rocket science, but it works.

## Documentation

For those who actually read documentation:
- [API Reference](https://pub.dev/documentation/cache_network_media/latest/)
- [Architecture Details](ARCHITECTURE.md) - For the curious developers
- [Contributing Guidelines](CONTRIBUTING.md) - For the brave souls

## Performance

Benchmarked? Not yet. Fast? Absolutely. Faster than downloading the same image 47 times? Definitely.

## Contributing

Found a bug? Have a feature request? Think you can make this better?

Read [CONTRIBUTING.md](CONTRIBUTING.md) first. Seriously, read it. We have standards.

## License

MIT License. Use it, abuse it, just don't blame us when your app breaks.

See [LICENSE](LICENSE) file for the legal stuff.

## Author

Created by **@D-extremity** - A developer who was tired of implementing the same caching logic for the 12th time.

GitHub: [@D-extremity](https://github.com/D-extremity)

## Support

If this package saved you time (and sanity), consider:
- Starring the repo on [GitHub](https://github.com/D-extremity/cache_network_media)
- Telling your fellow developers
- Actually reading the documentation before opening issues

## FAQ

**Q: Why another caching package?**  
A: Because existing solutions didn't handle SVG and Lottie the way we wanted.

**Q: Is it production-ready?**  
A: Define "production." Use at your own risk.

**Q: Can I use this in my enterprise app?**  
A: Sure, if your enterprise approves MIT-licensed packages.

---

*Cache Network Media - Making network media caching less painful since 2025.*
