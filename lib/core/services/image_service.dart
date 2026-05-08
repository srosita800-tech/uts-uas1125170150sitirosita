import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickAndCropImage(BuildContext context) async {
    // 1. Pick Image
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Tambahan: kompres awal agar tidak terlalu berat
    );
    
    if (pickedFile == null) return null;

    // PERBAIKAN: Cek apakah context masih aktif sebelum masuk ke Cropper
    // Ini menghilangkan peringatan "Don't use BuildContext across async gaps"
    if (!context.mounted) return null;

    // 2. Crop Image
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressQuality: 80,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Catalog LaptopProduction Cropper',
          toolbarColor: Colors.redAccent,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          // Tambahan: Pastikan tampilan penuh (full screen) agar user tidak bingung
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Catalog LaptopCropper',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    
    return null; // User membatalkan proses cropping
  }
}