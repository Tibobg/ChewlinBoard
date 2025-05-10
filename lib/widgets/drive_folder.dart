import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DriveGallery extends StatefulWidget {
  const DriveGallery({super.key});

  @override
  State<DriveGallery> createState() => _DriveGalleryState();
}

class _DriveGalleryState extends State<DriveGallery> {
  List<String> imageUrls = [];
  bool isLoading = true;

  final String folderId = '1N6R2DfseVo9We6wRQoS-Mqdzc_tg5TtU';
  final String apiKey = 'AIzaSyCxHIowhgMNEQCNCkINKGsFqztbix_4o_g';

  @override
  void initState() {
    super.initState();
    fetchImagesFromDrive();
  }

  Future<void> fetchImagesFromDrive() async {
    final url =
        "https://www.googleapis.com/drive/v3/files?q='$folderId'+in+parents+and+mimeType='image/jpeg'&key=$apiKey&fields=files(id,name)";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final files = data['files'] as List;

      final urls =
          files.map<String>((file) {
            final id = file['id'];
            return 'https://drive.google.com/uc?export=view&id=$id';
          }).toList();

      setState(() {
        imageUrls = urls;
        isLoading = false;
      });
    } else {
      print("Erreur lors de la récupération des images : ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (imageUrls.isEmpty) {
      return const Center(child: Text("Aucune image trouvée."));
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrls[index],
                width: 160,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}
