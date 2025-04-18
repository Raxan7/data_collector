import 'dart:io';
import 'package:cloudinary/cloudinary.dart';

class CloudinaryService {
  static final cloudinary = Cloudinary.signedConfig(
    apiKey: '463778388412657',
    apiSecret: '-ohofO2WCM2YdwCgbGfocwCsGNs',
    cloudName: 'dvbdol5uj',
  );

  static Future<String?> uploadImage(String filePath) async {
    try {
      final response = await cloudinary.upload(
        file: filePath, // Pass the file path as a String
        resourceType: CloudinaryResourceType.image,
        folder: "tanga_tech_reports",
      );
      return response.secureUrl;
    } catch (e) {
      print('Cloudinary upload error: $e');
      return null;
    }
  }
}