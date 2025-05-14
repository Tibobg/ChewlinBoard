import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/colors.dart';

class FullGalleryPage extends StatefulWidget {
  const FullGalleryPage({super.key});

  @override
  State<FullGalleryPage> createState() => _FullGalleryPageState();
}

class _FullGalleryPageState extends State<FullGalleryPage> {
  final String folderId = '1N6R2DfseVo9We6wRQoS-Mqdzc_tg5TtU';
  final String apiKey = 'AIzaSyCxHIowhgMNEQCNCkINKGsFqztbix_4o_g';

  List<String> imageUrls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllImages();
  }

  Future<void> fetchAllImages() async {
    final url =
        "https://www.googleapis.com/drive/v3/files?q='$folderId'+in+parents+and+mimeType='image/jpeg'&orderBy=createdTime+desc&key=$apiKey&fields=files(id,name)";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final files = data['files'] as List;

      final urls =
          files.map<String>((file) {
            final id = file['id'];
            return 'https://drive.google.com/thumbnail?id=$id&sz=w600';
          }).toList();

      setState(() {
        imageUrls = urls;
        isLoading = false;
      });
    } else {
      print("Erreur lors de la récupération des images : ${response.body}");
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
                        left: 16,
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
                        right: 16,
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

  void _launchLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint("Impossible d'ouvrir le lien : \$url");
    }
  }

  Widget _buildSocialButton(
    String label,
    String url,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () => _launchLink(url),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: color.withOpacity(0.9),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Galerie complète",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.beige,
                              fontFamily: 'ReginaBlack',
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Découvrez toutes mes planches customisées",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.beige,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSocialButton(
                          "Instagram",
                          "https://www.instagram.com/chewlin.pics?igsh=MTNoenJmMXRhYXg3bQ==",
                          Icons.camera_alt,
                          Colors.pink,
                        ),
                        _buildSocialButton(
                          "TikTok",
                          "https://www.tiktok.com/@chewlincorp?_t=ZN-8wM4sgM4wmE&_r=1",
                          Icons.music_note,
                          Colors.black,
                        ),
                      ],
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  isLoading
                      ? const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    MediaQuery.of(context).size.width > 600
                                        ? 3
                                        : 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio:
                                    0.5, // plus haut pour skateboard
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final url = imageUrls[index];
                            return GestureDetector(
                              onTap: () => showFullScreenGallery(index),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: url,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) => Container(
                                        color: Colors.grey.shade800,
                                      ),
                                  errorWidget:
                                      (context, url, error) => const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      ),
                                ),
                              ),
                            );
                          }, childCount: imageUrls.length),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
