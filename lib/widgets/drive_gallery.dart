import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:photo_view/photo_view.dart';

class DriveGallery extends StatefulWidget {
  const DriveGallery({super.key});

  @override
  State<DriveGallery> createState() => _DriveGalleryState();
}

class _DriveGalleryState extends State<DriveGallery> {
  final ScrollController _scrollController = ScrollController();
  List<String> imageUrls = [];
  bool isLoading = true;
  Timer? _scrollTimer;
  Timer? _resumeTimer;

  final String folderId = '1N6R2DfseVo9We6wRQoS-Mqdzc_tg5TtU';
  final String apiKey = 'AIzaSyCxHIowhgMNEQCNCkINKGsFqztbix_4o_g';

  void stopAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = null;

    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(seconds: 3), () {
      startAutoScroll();
    });
  }

  void startAutoScroll() {
    const scrollSpeed = 0.20;

    _scrollTimer = Timer.periodic(const Duration(milliseconds: 25), (_) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final current = _scrollController.offset;

        if (current < maxScroll) {
          _scrollController.jumpTo(current + scrollSpeed);
        } else {
          _scrollController.jumpTo(0);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchImagesFromDrive();
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
    _resumeTimer?.cancel();
  }

  Future<void> fetchImagesFromDrive() async {
    final url =
        "https://www.googleapis.com/drive/v3/files?q='$folderId'+in+parents+and+mimeType='image/jpeg'&fields=files(id,name)&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final files = data['files'] as List;

      // Trie les fichiers par numéro décroissant (ex: 22.jpg à 1.jpg)
      files.sort((a, b) {
        final numA =
            int.tryParse(
              RegExp(r'(\d+)\.jpg').firstMatch(a['name'])?.group(1) ?? '0',
            ) ??
            0;
        final numB =
            int.tryParse(
              RegExp(r'(\d+)\.jpg').firstMatch(b['name'])?.group(1) ?? '0',
            ) ??
            0;
        return numB.compareTo(numA);
      });

      final urls =
          files.take(5).map<String>((file) {
            final id = file['id'];
            return 'https://drive.google.com/thumbnail?id=$id&sz=w600';
          }).toList();

      setState(() {
        imageUrls = urls;
        isLoading = false;
      });

      for (final url in urls) {
        precacheImage(CachedNetworkImageProvider(url), context);
      }

      startAutoScroll();
    } else {
      print("Erreur lors de la récupération des images : \${response.body}");
    }
  }

  void showFullScreenGallery(int initialIndex) {
    final PageController pageController = PageController(
      initialPage: initialIndex,
    );
    int currentPage = initialIndex;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: const SizedBox.expand(),
                ),
                Center(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 48,
                        ),
                        child: PhotoView.customChild(
                          backgroundDecoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.covered * 2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 1.5,
                                height:
                                    MediaQuery.of(context).size.height * 0.7,
                                child: PageView.builder(
                                  controller: pageController,
                                  itemCount: imageUrls.length,
                                  onPageChanged:
                                      (index) =>
                                          setState(() => currentPage = index),
                                  itemBuilder: (context, index) {
                                    return Center(
                                      child: Image.network(
                                        imageUrls[index],
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 55,
                        right: 32,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close, color: Colors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        top: MediaQuery.of(context).size.height / 2 - 24,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () {
                            if (currentPage > 0) {
                              currentPage--;
                              pageController.animateToPage(
                                currentPage,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                        ),
                      ),
                      Positioned(
                        right: 20,
                        top: MediaQuery.of(context).size.height / 2 - 24,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () {
                            if (currentPage < imageUrls.length - 1) {
                              currentPage++;
                              pageController.animateToPage(
                                currentPage,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (imageUrls.isEmpty) {
      return const Center(child: Text("Aucune image trouvée."));
    }

    return NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        stopAutoScroll();
        return false;
      },
      child: GestureDetector(
        onTap: stopAutoScroll,
        child: SizedBox(
          height: 200,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  stopAutoScroll();
                  showFullScreenGallery(index);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: imageUrls[index],
                      width: 160,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey.shade800,
                            highlightColor: Colors.grey.shade600,
                            child: Container(
                              width: 160,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
