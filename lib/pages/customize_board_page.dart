import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import '../theme/colors.dart';
import '../widgets/app_header.dart';
import '../pages/editor_board_page.dart';
import '../models/project_data.dart';

class CustomizeBoardPage extends StatefulWidget {
  final ProjectData project;

  const CustomizeBoardPage({super.key, required this.project});

  @override
  State<CustomizeBoardPage> createState() => _CustomizeBoardPageState();
}

class _CustomizeBoardPageState extends State<CustomizeBoardPage> {
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<String> uploadImageToFirebase(File imageFile) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef = FirebaseStorage.instance.ref().child(
      'project_images/$fileName.jpg',
    );
    final uploadTask = await storageRef.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> _onFinalize() async {
    if (_selectedImage != null && _descriptionController.text.isNotEmpty) {
      widget.project.description = _descriptionController.text;

      // Upload image and store its URL
      try {
        final imageUrl = await uploadImageToFirebase(_selectedImage!);
        widget.project.imagePaths = [imageUrl];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditorBoardPage(project: widget.project),
          ),
        );
      } catch (e, stack) {
        debugPrint('Erreur Firebase Storage : $e');
        debugPrint('Stack trace : $stack');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'envoi de l'image.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Merci d'ajouter une image et une description"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppHeader(showBackButton: true),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Le design',
                        style: TextStyle(
                          color: AppColors.beige,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'ReginaBlack',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        widget.project.boardName,
                        style: const TextStyle(
                          color: AppColors.beige,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.black.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Description du design souhaité',
                            style: TextStyle(
                              color: AppColors.beige,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 5,
                            style: const TextStyle(color: AppColors.beige),
                            decoration: InputDecoration(
                              hintText: 'Écrire votre description ici...',
                              hintStyle: const TextStyle(
                                color: AppColors.beige,
                              ),
                              filled: true,
                              fillColor: AppColors.black,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.green,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Choisir une image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.beige,
                          foregroundColor: AppColors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    if (_selectedImage != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _onFinalize,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 14,
                          ),
                        ),
                        child: const Text(
                          'Finaliser',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.beige,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
