import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/db_service.dart';
import '../models/technical_report.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final List<String> _reportTypes = ['LUKU', 'FUEL'];
  String? _selectedReportType;
  String? _plcDisplayPhotoPath;
  String? _lukuBeforePhotoPath;
  String? _lukuAfterPhotoPath;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController technicianNameController = TextEditingController();
  final TextEditingController reportTypeController = TextEditingController();
  final TextEditingController siteIdController = TextEditingController();
  final TextEditingController fuelRemainingBeforeController = TextEditingController();
  final TextEditingController fuelAddedController = TextEditingController();
  final TextEditingController genRunningHoursController = TextEditingController();
  final TextEditingController lukuUnitsBeforeController = TextEditingController();
  final TextEditingController lukuUnitsAfterController = TextEditingController();

  Future<void> _takePhoto(String photoType) async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        switch (photoType) {
          case 'plc':
            _plcDisplayPhotoPath = image.path;
            break;
          case 'luku_before':
            _lukuBeforePhotoPath = image.path;
            break;
          case 'luku_after':
            _lukuAfterPhotoPath = image.path;
            break;
        }
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.saveAndValidate()) {
      try {
        final report = TechnicalReport(
          id: '', // Firestore will auto-generate ID
          title: titleController.text,
          description: descriptionController.text,
          technicianName: technicianNameController.text,
          reportType: reportTypeController.text,
          siteId: siteIdController.text,
          createdAt: DateTime.now(),
          timestamp: DateTime.now(),
          fuelRemainingBefore: fuelRemainingBeforeController.text.isNotEmpty
              ? double.tryParse(fuelRemainingBeforeController.text)
              : null,
          fuelAdded: fuelAddedController.text.isNotEmpty
              ? double.tryParse(fuelAddedController.text)
              : null,
          genRunningHours: genRunningHoursController.text.isNotEmpty
              ? double.tryParse(genRunningHoursController.text)
              : null,
          plcDisplayPhotoUrl: _plcDisplayPhotoPath,
          lukuUnitsBefore: lukuUnitsBeforeController.text.isNotEmpty
              ? double.tryParse(lukuUnitsBeforeController.text)
              : null,
          lukuUnitsAfter: lukuUnitsAfterController.text.isNotEmpty
              ? double.tryParse(lukuUnitsAfterController.text)
              : null,
          lukuBeforePhotoUrl: _lukuBeforePhotoPath,
          lukuAfterPhotoUrl: _lukuAfterPhotoPath,
        );
        
        await DBService.addEntry(report);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully!')),
        );
        _resetForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: ${e.toString()}')),
        );
      }
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _selectedReportType = null;
      _plcDisplayPhotoPath = null;
      _lukuBeforePhotoPath = null;
      _lukuAfterPhotoPath = null;
    });
    titleController.clear();
    descriptionController.clear();
    technicianNameController.clear();
    reportTypeController.clear();
    siteIdController.clear();
    fuelRemainingBeforeController.clear();
    fuelAddedController.clear();
    genRunningHoursController.clear();
    lukuUnitsBeforeController.clear();
    lukuUnitsAfterController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tanga Tech Tool - New Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField('technicianName', 'Name of Technical', true),
              
              FormBuilderDropdown<String>(
                name: 'reportType',
                decoration: const InputDecoration(
                  labelText: 'Select Report Type',
                  border: OutlineInputBorder(),
                ),
                items: _reportTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                validator: (value) =>
                    value == null ? 'Please select report type' : null,
                onChanged: (value) => setState(() => _selectedReportType = value),
              ),
              
              _buildTextField('siteId', 'SITE ID', true),
              
              if (_selectedReportType == 'FUEL') ...[
                const SizedBox(height: 16),
                const Text('Fuel Report Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                _buildNumberField('fuelRemainingBefore', 'Fuel Remain Before Adding', true),
                _buildNumberField('fuelAdded', 'Fuel Added', true),
                _buildNumberField('genRunningHours', 'Gen Running Hours', true),
                
                if (_plcDisplayPhotoPath != null) 
                  _buildPhotoPreview(_plcDisplayPhotoPath!),
                
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Picture of PLC Display'),
                  onPressed: () => _takePhoto('plc'),
                ),
              ],
              
              if (_selectedReportType == 'LUKU') ...[
                const SizedBox(height: 16),
                const Text('LUKU Report Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                _buildNumberField('lukuUnitsBefore', 'Luku Remain Units Before Add', true),
                _buildNumberField('lukuUnitsAfter', 'Luku Units After Added', true),
                
                if (_lukuBeforePhotoPath != null) 
                  _buildPhotoPreview(_lukuBeforePhotoPath!),
                
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Picture Before Add Units'),
                  onPressed: () => _takePhoto('luku_before'),
                ),
                
                if (_lukuAfterPhotoPath != null) 
                  _buildPhotoPreview(_lukuAfterPhotoPath!),
                
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Picture After Add Units'),
                  onPressed: () => _takePhoto('luku_after'),
                ),
              ],
              
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.red,
                      ),
                      onPressed: _resetForm,
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _submitForm,
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String name, String label, bool required) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FormBuilderTextField(
        name: name,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (value) => value == null || value.isEmpty 
                ? 'This field is required' 
                : null
            : null,
      ),
    );
  }

  Widget _buildNumberField(String name, String label, bool required) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FormBuilderTextField(
        name: name,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        validator: required
            ? (value) {
                if (value == null || value.isEmpty) return 'This field is required';
                if (double.tryParse(value) == null) return 'Enter valid number';
                return null;
              }
            : null,
      ),
    );
  }

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