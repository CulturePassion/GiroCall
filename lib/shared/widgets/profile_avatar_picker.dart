import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';
import '../../core/design/tokens.dart';

/// Tap-to-upload profile photo with preview.
class ProfileAvatarPicker extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final bool uploading;
  final bool readonly;
  final double radius;
  final ValueChanged<({Uint8List bytes, String mimeType})>? onImagePicked;

  const ProfileAvatarPicker({
    super.key,
    this.imageUrl,
    required this.initials,
    this.uploading = false,
    this.readonly = false,
    this.radius = 56,
    this.onImagePicked,
  });

  Future<void> _pick(BuildContext context, ImageSource source) async {
    if (onImagePicked == null || uploading) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    final mime = _mimeFromName(file.name);
    onImagePicked!((bytes: bytes, mimeType: mime));
  }

  String _mimeFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  void _showSourceSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pick(context, ImageSource.gallery);
              },
            ),
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pick(context, ImageSource.camera);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final letter =
        initials.trim().isNotEmpty ? initials.trim()[0].toUpperCase() : '?';
    final diameter = radius * 2;
    final canEdit = !readonly && onImagePicked != null;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            GestureDetector(
              onTap: canEdit && !uploading
                  ? () => _showSourceSheet(context)
                  : null,
              child: Container(
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                  gradient: imageUrl == null
                      ? const LinearGradient(
                          colors: [AppColors.main, AppColors.royalBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  image: imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.7),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.main.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: imageUrl == null
                    ? Center(
                        child: Text(
                          letter,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: radius * 0.7,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
            if (uploading)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            else if (canEdit)
              Material(
                color: AppColors.orange,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _showSourceSheet(context),
                  child: const SizedBox(
                    width: AppTokens.minTouchTarget,
                    height: AppTokens.minTouchTarget,
                    child:
                        Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ),
          ],
        ),
        if (canEdit) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Tap to upload profile photo',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
