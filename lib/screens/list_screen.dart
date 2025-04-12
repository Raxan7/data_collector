import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/db_service.dart';
import '../services/export_service.dart';
import '../models/technical_report.dart';
import '../services/auth_service.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tanga Tech Tool - Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportData,
            tooltip: 'Export to CSV',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: StreamBuilder<List<TechnicalReport>>(
        stream: DBService.getAllEntriesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final reports = snapshot.data ?? [];
          
          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final entry = reports[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(entry.technicianName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${entry.reportType} - ${entry.siteId}'),
                      Text('Submitted: ${dateFormat.format(entry.timestamp)}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteEntry(entry.id),
                  ),
                  onTap: () => _showDetails(entry),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteEntry(String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('Are you sure you want to delete this report?'),
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
        await DBService.deleteEntry(docId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report deleted successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete report: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _exportData() async {
    try {
      // Get current data from the stream
      final data = await DBService.getAllEntriesStream().first;
      await ExportService.exportToCSV(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data exported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: ${e.toString()}')),
      );
    }
  }

  void _showDetails(TechnicalReport entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${entry.reportType} Report - ${entry.siteId}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Technician', entry.technicianName),
              _buildDetailRow('Site ID', entry.siteId),
              _buildDetailRow('Submitted', dateFormat.format(entry.timestamp)),
              
              if (entry.reportType == 'FUEL') ...[
                const Divider(),
                const Text('Fuel Details', 
                  style: TextStyle(fontWeight: FontWeight.bold)),
                _buildDetailRow('Fuel Before', '${entry.fuelRemainingBefore?.toStringAsFixed(2) ?? 'N/A'} L'),
                _buildDetailRow('Fuel Added', '${entry.fuelAdded?.toStringAsFixed(2) ?? 'N/A'} L'),
                _buildDetailRow('Gen Hours', '${entry.genRunningHours?.toStringAsFixed(2) ?? 'N/A'} hrs'),
                
                if (entry.plcDisplayPhotoUrl != null && entry.plcDisplayPhotoUrl!.startsWith('http')) ...[
                  const SizedBox(height: 8),
                  const Text('PLC Display Photo:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
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
                const Text('LUKU Details', 
                  style: TextStyle(fontWeight: FontWeight.bold)),
                _buildDetailRow('Units Before', '${entry.lukuUnitsBefore?.toStringAsFixed(2) ?? 'N/A'}'),
                _buildDetailRow('Units After', '${entry.lukuUnitsAfter?.toStringAsFixed(2) ?? 'N/A'}'),
                
                if (entry.lukuBeforePhotoUrl != null && entry.lukuBeforePhotoUrl!.startsWith('http')) ...[
                  const SizedBox(height: 8),
                  const Text('Before Photo:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                  Image.network(
                    entry.lukuBeforePhotoUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ],
                
                if (entry.lukuAfterPhotoUrl != null && entry.lukuAfterPhotoUrl!.startsWith('http')) ...[
                  const SizedBox(height: 8),
                  const Text('After Photo:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
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

  // Keep your existing _takePhoto method, but update the preview:
  Widget _buildPhotoPreview(String path) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(path),
          height: 150,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}