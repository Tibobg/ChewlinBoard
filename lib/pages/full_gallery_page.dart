import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/colors.dart';

class FullGalleryPage extends StatefulWidget {
  const FullGalleryPage({super.key});

  @override
  State<FullGalleryPage> createState() => _FullGalleryPageState();
}

class _FullGalleryPageState extends State<FullGalleryPage> {
  String _sortBy = 'createdAt_desc';

  Query<Map<String, dynamic>> getSortedQuery() {
    final base = FirebaseFirestore.instance.collection('skateboards');
    switch (_sortBy) {
      case 'createdAt_asc':
        return base.orderBy('createdAt', descending: false);
      case 'price_asc':
        return base
            .where('isSold', isEqualTo: false)
            .orderBy('price', descending: false);
      case 'price_desc':
        return base
            .where('isSold', isEqualTo: false)
            .orderBy('price', descending: true);
      default:
        return base.orderBy('createdAt', descending: true);
    }
  }

  void showFullScreenGallery(List<DocumentSnapshot> docs, int initialIndex) {
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
                                  itemCount: docs.length,
                                  onPageChanged:
                                      (index) =>
                                          setState(() => currentPage = index),
                                  itemBuilder: (context, index) {
                                    final data =
                                        docs[index].data()
                                            as Map<String, dynamic>;
                                    final imageUrl = data['imageUrl'] ?? '';
                                    final thumbUrl =
                                        data['thumbUrl'] ?? imageUrl;
                                    final isSold = data['isSold'] ?? false;
                                    return Stack(
                                      children: [
                                        Center(
                                          child: CachedNetworkImage(
                                            imageUrl: thumbUrl,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 20,
                                          left: 20,
                                          right: 20,
                                          child: ElevatedButton(
                                            onPressed: isSold ? null : () {},
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  isSold
                                                      ? Colors.grey
                                                      : Colors.green,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                            ),
                                            child: Text(
                                              isSold ? 'Vendu' : 'Acheter',
                                            ),
                                          ),
                                        ),
                                      ],
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
                            if (currentPage < docs.length - 1) {
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
                          "https://www.instagram.com/chewlin.pics",
                          Icons.camera_alt,
                          Colors.pink,
                        ),
                        _buildSocialButton(
                          "TikTok",
                          "https://www.tiktok.com/@chewlincorp",
                          Icons.music_note,
                          Colors.black,
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: DropdownButton<String>(
                        value: _sortBy,
                        dropdownColor: Colors.black,
                        style: const TextStyle(color: Colors.white),
                        iconEnabledColor: Colors.white,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'createdAt_desc',
                            child: Text('Récent (desc)'),
                          ),
                          DropdownMenuItem(
                            value: 'createdAt_asc',
                            child: Text('Récent (asc)'),
                          ),
                          DropdownMenuItem(
                            value: 'price_asc',
                            child: Text('Prix croissant'),
                          ),
                          DropdownMenuItem(
                            value: 'price_desc',
                            child: Text('Prix décroissant'),
                          ),
                        ],
                        onChanged:
                            (value) => setState(
                              () => _sortBy = value ?? 'createdAt_desc',
                            ),
                      ),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: getSortedQuery().snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final docs = snapshot.data!.docs;
                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 1 / 2.0,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;
                            final imageUrl = data['imageUrl'] ?? '';
                            final thumbUrl = data['thumbUrl'] ?? imageUrl;
                            final isSold = data['isSold'] ?? false;
                            final price = data['price'] ?? 'À définir';
                            return GestureDetector(
                              onTap: () => showFullScreenGallery(docs, index),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: AspectRatio(
                                      aspectRatio:
                                          1 /
                                          2.0, // 🔥 pour un rendu plus vertical
                                      child: CachedNetworkImage(
                                        imageUrl: thumbUrl,
                                        fit:
                                            BoxFit
                                                .cover, // 🧲 zoom naturel dans le cadre
                                        placeholder:
                                            (context, url) => const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                        errorWidget:
                                            (context, url, error) =>
                                                const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isSold
                                                ? Colors.grey.withOpacity(0.8)
                                                : Colors.green.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isSold ? 'Vendu' : price,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }, childCount: docs.length),
                        ),
                      );
                    },
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
