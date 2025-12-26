import 'package:flutter/material.dart';
import 'package:cache_network_media/cache_network_media.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Cache Network Media'),
          backgroundColor: Colors.blueAccent,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Image Example',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CacheNetworkMediaWidget.img(
                url: 'https://picsum.photos/400/300',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                placeholder: const Center(child: CircularProgressIndicator()),
              ),

              const SizedBox(height: 24),
              const Text(
                'SVG Example',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CacheNetworkMediaWidget.svg(
                    url: 'https://www.svgrepo.com/show/13664/heart.svg',
                    width: 80,
                    height: 80,
                    color: Colors.red,
                  ),
                  CacheNetworkMediaWidget.svg(
                    url: 'https://www.svgrepo.com/show/22031/star.svg',
                    width: 80,
                    height: 80,
                    color: Colors.amber,
                  ),
                  CacheNetworkMediaWidget.svg(
                    url: 'https://www.svgrepo.com/show/80156/like.svg',
                    width: 80,
                    height: 80,
                    color: Colors.blue,
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text(
                'Lottie Animation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Center(
                child: CacheNetworkMediaWidget.lottie(
                  url:
                      'https://lottie.host/2480c7b2-c4ee-4069-b65a-0f28c0ba9a64/SYXSWpC1Hv.json',
                  width: 200,
                  height: 200,
                  repeat: true,
                  animate: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
