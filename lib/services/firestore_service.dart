import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/technical_report.dart';

class FirebaseService {
  static final CollectionReference _reportsCollection = 
      FirebaseFirestore.instance.collection('technical_reports');
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<void> addReport(TechnicalReport report) async {
    await _reportsCollection.add(report.toFirestore());
  }

  static Stream<List<TechnicalReport>> getReportsStream() {
    return _reportsCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TechnicalReport.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
            .toList());
  }

  static Future<void> deleteReport(String docId) async {
    await _reportsCollection.doc(docId).delete();
  }

  static Future<String> uploadImage(String filePath) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${filePath.split('/').last}';
      final ref = _storage.ref().child('report_images/$fileName');
      final uploadTask = ref.putFile(File(filePath));
      final taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }
}