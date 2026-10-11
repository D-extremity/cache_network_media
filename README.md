# Cache Network Media

**`cached_network_image`, but for SVG and Lottie too.**

Cache Network Media is a Flutter package that downloads network **images, SVGs and Lottie animations once**, stores them on disk, and shows them instantly (and offline) from then on.

`SvgPicture.network` ([flutter_svg](https://pub.dev/packages/flutter_svg)) and `Lottie.network` ([lottie](https://pub.dev/packages/lottie)) do not keep a disk cache, so the same file is downloaded again on every cold start. This package adds that cache, with one widget for all three media types.

[![pub package](https://img.shields.io/pub/v/cache_network_media.svg)](https://pub.dev/packages/cache_network_media)
[![GitHub](https://img.shields.io/github/license/D-extremity/cache_network_media)](https://github.com/D-extremity/cache_network_media/blob/main/LICENSE)
[![CI](https://github.com/D-extremity/cache_network_media/actions/workflows/ci.yml/badge.svg)](https://github.com/D-extremity/cache_network_media/actions/workflows/ci.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.29+-blue.svg)](https://flutter.dev)

<p align="center">
  <img src="doc/demo.gif" alt="An animated bird loaded from the disk cache by Cache Network Media" width="320">
</p>

## Contents

- [Why use it](#why-use-it)
- [Install](#install)
- [Quick start](#quick-start)
- [Migrating from cached_network_image](#migrating-from-cached_network_image)
- [Common tasks](#common-tasks)
- [API reference](#api-reference)
- [How caching works](#how-caching-works)
- [Platform support](#platform-support)
- [FAQ](#faq)
- [Contributing and license](#contributing-and-license)

## Why use it

| You get | Details |
|---|---|
| **One widget for three formats** | PNG, JPG, WebP, GIF and BMP images, SVG graphics and Lottie JSON animations |
| **Persistent disk cache** | Files survive app restarts, so media loads without a network request after the first download |
| **Offline support** | Cached media still shows with no connection. Expired copies are used when a refresh fails |
| **Real-world requests** | Request `headers` for authenticated CDNs, a `timeout`, and download progress |
| **One download per URL** | 20 list items showing the same avatar trigger a single download, over one shared HTTP client |
| **List-friendly** | `lazyLoading` waits until an item scrolls into view. Rebuilds never reload the media |
| **Cache control** | `maxAge`, `maxCacheSizeBytes`, `prefetch`, `evict` and `clear` |
| **Pure Dart** | No Kotlin, Swift, Gradle or CocoaPods setup. Works on Android, iOS, macOS, Windows and Linux |

### How it compares

| | `cache_network_media` | `cached_network_image` | `SvgPicture.network` | `Lottie.network` |
|---|:---:|:---:|:---:|:---:|
| Images with disk cache | ✅ | ✅ | ❌ | ❌ |
| SVG with disk cache | ✅ | ❌ | ❌ | ❌ |
| Lottie with disk cache | ✅ | ❌ | ❌ | ❌ |
| Works as an `ImageProvider` | ✅ | ✅ | ❌ | ❌ |

## Install

```bash
flutter pub add cache_network_media
```

Or add it to `pubspec.yaml`:

```yaml
dependencies:
  cache_network_media: ^1.1.0
```

Then import it:

```dart
import 'package:cache_network_media/cache_network_media.dart';
```

## Quick start

### Cached network image

```dart
CacheNetworkMediaWidget.img(
  url: 'https://example.com/image.png',
  width: 200,
  height: 200,
  fit: BoxFit.cover,
  placeholder: const CircularProgressIndicator(),
  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
)
```

### Cached SVG

```dart
CacheNetworkMediaWidget.svg(
  url: 'https://example.com/icon.svg',
  width: 100,
  height: 100,
  color: Colors.blue,
)
```

### Cached Lottie animation

```dart
CacheNetworkMediaWidget.lottie(
  url: 'https://example.com/animation.json',
  width: 300,
  height: 300,
  repeat: true,
)
```

### As an `ImageProvider`

`CacheNetworkMediaImageProvider` uses the same disk cache and works anywhere Flutter accepts an `ImageProvider`:

```dart
CircleAvatar(
  backgroundImage: CacheNetworkMediaImageProvider('https://example.com/avatar.png'),
)
```

## Migrating from cached_network_image

The widgets map one to one. Here is the most common case:

```dart
// Before
CachedNetworkImage(
  imageUrl: 'https://example.com/image.png',
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)

// After
CacheNetworkMediaWidget.img(
  url: 'https://example.com/image.png',
  placeholder: const CircularProgressIndicator(),
  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
)
```

```dart
// Before
CircleAvatar(backgroundImage: CachedNetworkImageProvider(url))

// After
CircleAvatar(backgroundImage: CacheNetworkMediaImageProvider(url))
```

| cached_network_image | cache_network_media |
|---|---|
| `CachedNetworkImage(imageUrl: ...)` | `CacheNetworkMediaWidget.img(url: ...)` |
| `CachedNetworkImageProvider(url)` | `CacheNetworkMediaImageProvider(url)` |
| `placeholder: (context, url) => ...` | `placeholder: widget` |
| `progressIndicatorBuilder` | `progressBuilder: (context, progress) => ...` |
| `errorWidget: (context, url, error) => ...` | `errorBuilder: (context, error, stackTrace) => ...` |
| `httpHeaders` | `headers` |
| `memCacheWidth`, `memCacheHeight` | `memCacheWidth`, `memCacheHeight` |
| `DefaultCacheManager().emptyCache()` | `CacheNetworkMedia.clear()` |
| `DefaultCacheManager().removeFile(url)` | `CacheNetworkMedia.evict(url)` |
| `DefaultCacheManager().downloadFile(url)` | `CacheNetworkMedia.prefetch(url)` |

Things to know when switching:

- Files cached by `cached_network_image` are not reused. Each image downloads once more.
- Your SVG and Lottie code can switch from `SvgPicture.network(url)` and `Lottie.network(url)` to `CacheNetworkMediaWidget.svg(url: url)` and `CacheNetworkMediaWidget.lottie(url: url)`.

## Common tasks

### Show download progress

```dart
CacheNetworkMediaWidget.img(
  url: 'https://example.com/large-photo.jpg',
  progressBuilder: (context, progress) =>
      CircularProgressIndicator(value: progress.fraction),
)
```

`progress.received` and `progress.total` are in bytes. `progress.fraction` is `null` when the server sends no size, which shows the indeterminate animation. `progressBuilder` replaces `placeholder` while a download runs. It is not used when the file is already cached.

### Load from a CDN that needs authentication

```dart
CacheNetworkMediaWidget.img(
  url: 'https://cdn.example.com/private/avatar.png',
  headers: {'Authorization': 'Bearer $token'},
  timeout: const Duration(seconds: 10),
)
```

`timeout` defaults to 30 seconds and fails the download when the server stops responding. The cache is keyed by URL only, so a cached file is served whatever headers you pass.

### Lazy-load long lists

```dart
ListView.builder(
  itemCount: 100,
  itemBuilder: (context, index) => CacheNetworkMediaWidget.img(
    url: 'https://example.com/image$index.png',
    height: 200,
    lazyLoading: true, // starts loading when the item becomes visible
  ),
)
```

### Set cache limits

Set these once, before `runApp`. They apply to images, SVGs and Lottie files:

```dart
void main() {
  // Download again after 7 days. While offline, the expired copy is still shown.
  CacheNetworkMedia.maxAge = const Duration(days: 7);

  // Keep the disk cache under 200 MB, deleting least recently used files first.
  CacheNetworkMedia.maxCacheSizeBytes = 200 * 1024 * 1024;

  runApp(const MyApp());
}
```

Both default to `null`: files never expire and the cache has no size limit.

### Prefetch, evict and clear

```dart
// Download ahead of time, for example before the user goes offline
await CacheNetworkMedia.prefetch('https://example.com/onboarding.json');

// Remove one file, for example after the user changes their avatar
await CacheNetworkMedia.evict('https://example.com/avatar.png');

// Remove everything, for example on logout
await CacheNetworkMedia.clear();
```

If you use a custom `cacheDirectory`, pass the same directory to these methods.

### Use a custom cache directory

```dart
CacheNetworkMediaWidget.img(
  url: 'https://example.com/image.png',
  cacheDirectory: Directory('/path/to/your/cache'),
)
```

### Save memory with thumbnails

Decode large images at the size you display them. Values are in physical pixels:

```dart
CacheNetworkMediaWidget.img(
  url: 'https://example.com/photo.jpg',
  width: 100,
  height: 100,
  memCacheWidth: (100 * MediaQuery.devicePixelRatioOf(context)).round(),
)
```

With `CacheNetworkMediaImageProvider`, wrap it in `ResizeImage(provider, width: 200)`.

### Tint SVGs and control Lottie playback

```dart
CacheNetworkMediaWidget.svg(
  url: 'https://example.com/icon.svg',
  colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
  semanticsLabel: 'App logo',
)

CacheNetworkMediaWidget.lottie(
  url: 'https://example.com/animation.json',
  repeat: false,
  reverse: true,
  frameRate: 60,
)
```

## API reference

Full generated docs: [pub.dev/documentation/cache_network_media](https://pub.dev/documentation/cache_network_media/latest/).

### Parameters for every media type

| Parameter | Type | Description |
|---|---|---|
| `url` | `String` | **Required.** The network URL of the media |
| `cacheDirectory` | `Directory?` | Custom cache directory. Uses the app cache directory if null |
| `headers` | `Map<String, String>?` | HTTP headers sent with the download |
| `timeout` | `Duration?` | How long the server may stay silent before the download fails. Default 30 seconds |
| `width`, `height` | `double?` | Size of the widget |
| `fit` | `BoxFit?` | How the media fills its box |
| `alignment` | `AlignmentGeometry` | Alignment inside the box. `AlignmentDirectional` is supported |
| `placeholder` | `Widget?` | Shown while loading |
| `progressBuilder` | `Widget Function(BuildContext, DownloadProgress)?` | Shown while downloading. Replaces `placeholder` |
| `errorBuilder` | `Widget Function(BuildContext, Object, StackTrace?)?` | Shown when loading fails |
| `onTap` | `VoidCallback?` | Called when the media is tapped |
| `lazyLoading` | `bool` | Wait until the widget is visible before loading. Default false |

### Image parameters (`.img`)

| Parameter | Type | Default | Description |
|---|---|---|---|
| `color`, `colorBlendMode` | `Color?`, `BlendMode?` | null | Blend a color into the image |
| `filterQuality` | `FilterQuality` | medium | Sampling quality |
| `repeat` | `ImageRepeat` | noRepeat | How to paint uncovered areas |
| `semanticLabel` | `String?` | null | Accessibility label |
| `memCacheWidth`, `memCacheHeight` | `int?` | null | Decode at this size, in physical pixels |
| `gaplessPlayback` | `bool` | false | Keep the old image while a new one loads |

### SVG parameters (`.svg`)

| Parameter | Type | Default | Description |
|---|---|---|---|
| `color` | `Color?` | null | Simple tint |
| `colorFilter` | `ColorFilter?` | null | Advanced color filtering |
| `theme` | `SvgTheme?` | null | SVG theme |
| `semanticsLabel` | `String?` | null | Accessibility label |

### Lottie parameters (`.lottie`)

| Parameter | Type | Default | Description |
|---|---|---|---|
| `repeat` | `bool` | true | Loop the animation |
| `reverse` | `bool` | false | Play in reverse |
| `animate` | `bool` | true | Start immediately |
| `frameRate` | `double?` | null | Custom frame rate |
| `delegates` | `LottieDelegates?` | null | Custom delegates |

### `CacheNetworkMedia`

| Member | Description |
|---|---|
| `maxAge` | How long a file stays fresh. `null` means forever |
| `maxCacheSizeBytes` | Disk cache size limit. `null` means unlimited |
| `prefetch(url, {cacheDirectory, headers, timeout})` | Download into the cache without showing |
| `evict(url, {cacheDirectory})` | Remove one file |
| `clear({cacheDirectory})` | Remove all cached files |

## How caching works

1. The widget asks for a URL.
2. If a fresh copy is on disk, it is returned immediately.
3. Otherwise the file is downloaded (once, even if many widgets ask for it at the same time), written to disk, and returned.
4. If the copy is older than `maxAge` and the new download fails, the old copy is shown.

**Where files are stored.** Files go in a `cache_network_media/` folder inside the directory returned by `getApplicationCacheDirectory()` from [path_provider](https://pub.dev/packages/path_provider), so each platform uses its own app cache location. Each file is named after the SHA-1 hash of its URL with a `.cache` extension, so file names stay short and safe however long the URL is.

**Safe writes.** Downloads are written to a temporary file and renamed when complete, so a killed app never leaves a half-written file that looks like a cache hit.

See [ARCHITECTURE.md](ARCHITECTURE.md) for the full design.

## Platform support

| Platform | Status |
|---|:---:|
| Android | ✅ |
| iOS | ✅ |
| macOS | ✅ |
| Windows | ✅ |
| Linux | ✅ |
| Web | ❌ The package uses `dart:io` and would need a separate storage backend |

## FAQ

**Does it cache Lottie and SVG files across app restarts?**
Yes. Images, SVGs and Lottie files are stored on disk and reused on the next launch.

**Does it work offline?**
Yes, for anything that was downloaded before. Expired files are still shown when a refresh fails.

**How do I clear the cache on logout?**
Call `await CacheNetworkMedia.clear()`.

**Can I use it with authenticated or signed URLs?**
Yes. Pass `headers` for token-based CDNs. Signed URLs work too, and the file name is a hash, so long query strings are fine. Because the cache is keyed by the full URL, a URL whose signature changes on every request is cached as a new file each time.

**Why doesn't `SvgPicture.network` or `Lottie.network` cache to disk?**
They load the file over the network on every cold start and keep nothing on disk. This package wraps the same renderers (`flutter_svg` and `lottie`) and adds the disk cache.

**Does it support Flutter web?**
Not yet. See [Platform support](#platform-support).

## Contributing and license

**Found a flaw, a bug or a missing feature? You are welcome to help.** Open an [issue](https://github.com/D-extremity/cache_network_media/issues) to report it, or send a pull request with a fix. Contributions of any size are appreciated, from typo fixes to new features.

Read [CONTRIBUTING.md](CONTRIBUTING.md) first, then:

```bash
git clone https://github.com/D-extremity/cache_network_media.git
cd cache_network_media
flutter pub get
flutter test
flutter analyze
dart format --set-exit-if-changed .
```

More documentation: [ARCHITECTURE.md](ARCHITECTURE.md) · [CHANGELOG.md](CHANGELOG.md).

MIT License. See [LICENSE](LICENSE).

Created by [@D-extremity](https://github.com/D-extremity). If this package helped you, star the [GitHub repository](https://github.com/D-extremity/cache_network_media), like it on [pub.dev](https://pub.dev/packages/cache_network_media), or [report an issue](https://github.com/D-extremity/cache_network_media/issues).
