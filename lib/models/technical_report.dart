import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'technical_report.g.dart';

@HiveType(typeId: 64) // Ensure typeId matches the generated adapter
class TechnicalReport {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String technicianName;

  @HiveField(4)
  final String reportType;

  @HiveField(5)
  final String siteId;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime timestamp;

  @HiveField(8)
  final double? fuelRemainingBefore;

  @HiveField(9)
  final double? fuelAdded;

  @HiveField(10)
  final double? genRunningHours;

  @HiveField(11)
  String? plcDisplayPhotoUrl; // Changed from plcDisplayPhotoPath

  @HiveField(12)
  final double? lukuUnitsBefore;

  @HiveField(13)
  final double? lukuUnitsAfter;

  @HiveField(14)
  String? lukuBeforePhotoUrl; // Changed from lukuBeforePhotoPath

  @HiveField(15)
  String? lukuAfterPhotoUrl; // Changed from lukuAfterPhotoPath

  TechnicalReport({
    required this.id,
    required this.title,
    required this.description,
    required this.technicianName,
    required this.reportType,
    required this.siteId,
    required this.createdAt,
    required this.timestamp,
    this.fuelRemainingBefore,
    this.fuelAdded,
    this.genRunningHours,
    this.plcDisplayPhotoUrl, // Updated field
    this.lukuUnitsBefore,
    this.lukuUnitsAfter,
    this.lukuBeforePhotoUrl, // Updated field
    this.lukuAfterPhotoUrl,  // Updated field
  });

  void updatePlcPhotoPath(String? url) => plcDisplayPhotoUrl = url;
  void updateLukuBeforePath(String? url) => lukuBeforePhotoUrl = url;
  void updateLukuAfterPath(String? url) => lukuAfterPhotoUrl = url;

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'technicianName': technicianName,
      'reportType': reportType,
      'siteId': siteId,
      'createdAt': Timestamp.fromDate(createdAt),
      'timestamp': Timestamp.fromDate(timestamp),
      'fuelRemainingBefore': fuelRemainingBefore,
      'fuelAdded': fuelAdded,
      'genRunningHours': genRunningHours,
      'plcDisplayPhotoUrl': plcDisplayPhotoUrl,
      'lukuUnitsBefore': lukuUnitsBefore,
      'lukuUnitsAfter': lukuUnitsAfter,
      'lukuBeforePhotoUrl': lukuBeforePhotoUrl,
      'lukuAfterPhotoUrl': lukuAfterPhotoUrl,
    };
  }

  factory TechnicalReport.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return TechnicalReport(
      id: data['id'] ?? doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      technicianName: data['technicianName'] ?? '',
      reportType: data['reportType'] ?? '',
      siteId: data['siteId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      fuelRemainingBefore: data['fuelRemainingBefore']?.toDouble(),
      fuelAdded: data['fuelAdded']?.toDouble(),
      genRunningHours: data['genRunningHours']?.toDouble(),
      plcDisplayPhotoUrl: data['plcDisplayPhotoUrl'],
      lukuUnitsBefore: data['lukuUnitsBefore']?.toDouble(),
      lukuUnitsAfter: data['lukuUnitsAfter']?.toDouble(),
      lukuBeforePhotoUrl: data['lukuBeforePhotoUrl'],
      lukuAfterPhotoUrl: data['lukuAfterPhotoUrl'],
    );
  }
}