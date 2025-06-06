import 'package:flutter/material.dart';
import '../models/technical_report.dart';
import '../services/db_service.dart'; // Add this import

class DetailScreen extends StatelessWidget {
  final TechnicalReport report;

  const DetailScreen({super.key, required this.report});

  Future<void> _deleteReport(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('Are you sure you want to delete this report? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        await DBService.deleteEntry(report.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report deleted successfully')),
          );
          Navigator.pop(context); // Go back to the previous screen
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete report: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteReport(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailCard(
              'Technician Information',
              [
                _buildDetailRow('Name', report.technicianName),
                _buildDetailRow('Site ID', report.siteId),
                _buildDetailRow('Report Type', report.reportType),
                _buildDetailRow('Date', 
                  '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}'),
                _buildDetailRow('Time', 
                  '${report.createdAt.hour}:${report.createdAt.minute}'),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (report.reportType == 'FUEL') ...[
              _buildDetailCard(
                'Fuel Details',
                [
                  if (report.fuelRemainingBefore != null)
                    _buildDetailRow('Fuel Remaining Before', 
                      '${report.fuelRemainingBefore} L'),
                  if (report.fuelAdded != null)
                    _buildDetailRow('Fuel Added', '${report.fuelAdded} L'),
                  if (report.genRunningHours != null)
                    _buildDetailRow('Generator Running Hours', 
                      '${report.genRunningHours} hours'),
                ],
              ),
              
              if (report.plcDisplayPhotoUrl != null) ...[
                const SizedBox(height: 16),
                _buildDetailCard(
                  'PLC Display Photo',
                  [
                    Center(
                      child: Image.network(
                        report.plcDisplayPhotoUrl!,
                        height: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text('Failed to load image'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
            
            if (report.reportType == 'LUKU') ...[
              _buildDetailCard(
                'LUKU Details',
                [
                  if (report.lukuUnitsBefore != null)
                    _buildDetailRow('Units Before', 
                      '${report.lukuUnitsBefore} units'),
                  if (report.lukuUnitsAfter != null)
                    _buildDetailRow('Units After', 
                      '${report.lukuUnitsAfter} units'),
                ],
              ),
              
              if (report.lukuBeforePhotoUrl != null) ...[
                const SizedBox(height: 16),
                _buildDetailCard(
                  'Before Units Photo',
                  [
                    Center(
                      child: Image.network(
                        report.lukuBeforePhotoUrl!,
                        height: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text('Failed to load image'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
              
              if (report.lukuAfterPhotoUrl != null) ...[
                const SizedBox(height: 16),
                _buildDetailCard(
                  'After Units Photo',
                  [
                    Center(
                      child: Image.network(
                        report.lukuAfterPhotoUrl!,
                        height: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text('Failed to load image'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
