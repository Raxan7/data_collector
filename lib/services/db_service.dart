import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/technical_report.dart';
import 'firestore_service.dart';
import 'cloudinary_service.dart';

class DBService {
  static Future<void> addEntry(TechnicalReport report) async {
    try {
      // Upload images to Cloudinary if they exist and are local files
      if (report.plcDisplayPhotoUrl != null && !report.plcDisplayPhotoUrl!.startsWith('http')) {
        final url = await CloudinaryService.uploadImage(report.plcDisplayPhotoUrl!);
        if (url != null) report.updatePlcPhotoPath(url);
      }
      
      if (report.lukuBeforePhotoUrl != null && !report.lukuBeforePhotoUrl!.startsWith('http')) {
        final url = await CloudinaryService.uploadImage(report.lukuBeforePhotoUrl!);
        if (url != null) report.updateLukuBeforePath(url);
      }
      
      if (report.lukuAfterPhotoUrl != null && !report.lukuAfterPhotoUrl!.startsWith('http')) {
        final url = await CloudinaryService.uploadImage(report.lukuAfterPhotoUrl!);
        if (url != null) report.updateLukuAfterPath(url);
      }
      
      // Add report to Firestore
      await FirebaseService.addReport(report);
    } catch (e) {
      print('Error adding report: $e');
      rethrow;
    }
  }

  static Stream<List<TechnicalReport>> getAllEntriesStream() {
    return FirebaseService.getReportsStream();
  }

  static Future<void> deleteEntry(String docId) async {
    if (docId.isEmpty) {
      throw Exception('Cannot delete report with empty ID');
    }
    await FirebaseService.deleteReport(docId);
  }
}