import 'package:flutter/material.dart';
import 'package:cache_network_media/cache_network_media.dart';

/// Example demonstrating lazy loading for CacheNetworkMediaWidget
///
/// This example shows how to use lazy loading to optimize performance
/// when displaying multiple media items in a scrollable list.
class LazyLoadingExample extends StatelessWidget {
  const LazyLoadingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lazy Loading Example')),
      body: ListView.builder(
        itemCount: 50,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Image with lazy loading enabled
                CacheNetworkMediaWidget.img(
                  url: 'https://picsum.photos/400/300?random=$index',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  lazyLoading: true, // Enable lazy loading
                  placeholder: const Center(child: CircularProgressIndicator()),
                ),
                const SizedBox(height: 8),
                Text('Image $index'),
                const Divider(),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Example with mixed media types (images, SVG, Lottie) using lazy loading
class MixedMediaLazyLoadingExample extends StatelessWidget {
  const MixedMediaLazyLoadingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mixed Media Lazy Loading')),
      body: ListView(
        children: [
          // Lazy loaded image
          Card(
            child: Column(
              children: [
                CacheNetworkMediaWidget.img(
                  url: 'https://picsum.photos/400/300',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  lazyLoading: true,
                ),
                const ListTile(
                  title: Text('Lazy Loaded Image'),
                  subtitle: Text('Loads when scrolled into view'),
                ),
              ],
            ),
          ),

          // Lazy loaded SVG
          Card(
            child: Column(
              children: [
                CacheNetworkMediaWidget.svg(
                  url: 'https://example.com/icon.svg',
                  width: 100,
                  height: 100,
                  lazyLoading: true,
                ),
                const ListTile(
                  title: Text('Lazy Loaded SVG'),
                  subtitle: Text('Deferred until visible'),
                ),
              ],
            ),
          ),

          // Lazy loaded Lottie animation
          Card(
            child: Column(
              children: [
                CacheNetworkMediaWidget.lottie(
                  url: 'https://example.com/animation.json',
                  width: 200,
                  height: 200,
                  lazyLoading: true,
                  repeat: true,
                ),
                const ListTile(
                  title: Text('Lazy Loaded Lottie'),
                  subtitle: Text('Animation starts when in view'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Comparison example: with and without lazy loading
class LazyLoadingComparisonExample extends StatelessWidget {
  const LazyLoadingComparisonExample({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lazy Loading Comparison'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Without Lazy Loading'),
              Tab(text: 'With Lazy Loading'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Without lazy loading - all images load immediately
            _buildMediaList(lazyLoading: false),

            // With lazy loading - images load as they appear
            _buildMediaList(lazyLoading: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaList({required bool lazyLoading}) {
    return ListView.builder(
      itemCount: 30,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CacheNetworkMediaWidget.img(
                url: 'https://picsum.photos/400/300?random=${index + 100}',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                lazyLoading: lazyLoading,
              ),
              ListTile(
                title: Text('Image $index'),
                subtitle: Text(lazyLoading ? 'Lazy loaded' : 'Immediate load'),
              ),
            ],
          ),
        );
      },
    );
  }
}
