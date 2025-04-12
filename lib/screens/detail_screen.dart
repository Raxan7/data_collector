import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/technical_report.dart';

class DetailScreen extends StatelessWidget {
  final TechnicalReport entry;

  DetailScreen({required this.entry});

  final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${entry.reportType} Report - ${entry.siteId}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Technician', entry.technicianName),
            _buildDetailRow('Site ID', entry.siteId),
            _buildDetailRow('Submitted', dateFormat.format(entry.timestamp)),
            if (entry.reportType == 'FUEL') ...[
              const Divider(),
              const Text('Fuel Details', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildDetailRow('Fuel Before', '${entry.fuelRemainingBefore?.toStringAsFixed(2) ?? 'N/A'} L'),
              _buildDetailRow('Fuel Added', '${entry.fuelAdded?.toStringAsFixed(2) ?? 'N/A'} L'),
              _buildDetailRow('Gen Hours', '${entry.genRunningHours?.toStringAsFixed(2) ?? 'N/A'} hrs'),
              if (entry.plcDisplayPhotoUrl != null && entry.plcDisplayPhotoUrl!.startsWith('http')) ...[
                const SizedBox(height: 8),
                const Text('PLC Display Photo:', style: TextStyle(fontWeight: FontWeight.bold)),
                Image.network(
                  entry.plcDisplayPhotoUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ],
            ],
            if (entry.reportType == 'LUKU') ...[
              const Divider(),
              const Text('LUKU Details', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildDetailRow('Units Before', '${entry.lukuUnitsBefore?.toStringAsFixed(2) ?? 'N/A'}'),
              _buildDetailRow('Units After', '${entry.lukuUnitsAfter?.toStringAsFixed(2) ?? 'N/A'}'),
              if (entry.lukuBeforePhotoUrl != null && entry.lukuBeforePhotoUrl!.startsWith('http')) ...[
                const SizedBox(height: 8),
                const Text('Before Photo:', style: TextStyle(fontWeight: FontWeight.bold)),
                Image.network(
                  entry.lukuBeforePhotoUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ],
              if (entry.lukuAfterPhotoUrl != null && entry.lukuAfterPhotoUrl!.startsWith('http')) ...[
                const SizedBox(height: 8),
                const Text('After Photo:', style: TextStyle(fontWeight: FontWeight.bold)),
                Image.network(
                  entry.lukuAfterPhotoUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
