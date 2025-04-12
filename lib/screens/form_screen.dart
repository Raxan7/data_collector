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
  File? _plcDisplayPhoto;
  File? _lukuBeforePhoto;
  File? _lukuAfterPhoto;

  // Controllers for all fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _technicianNameController = TextEditingController();
  final TextEditingController _siteIdController = TextEditingController();
  final TextEditingController _fuelRemainingBeforeController = TextEditingController();
  final TextEditingController _fuelAddedController = TextEditingController();
  final TextEditingController _genRunningHoursController = TextEditingController();
  final TextEditingController _lukuUnitsBeforeController = TextEditingController();
  final TextEditingController _lukuUnitsAfterController = TextEditingController();

  Future<void> _takePhoto(String photoType) async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        final file = File(image.path);
        switch (photoType) {
          case 'plc':
            _plcDisplayPhoto = file;
            break;
          case 'luku_before':
            _lukuBeforePhoto = file;
            break;
          case 'luku_after':
            _lukuAfterPhoto = file;
            break;
        }
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      try {
        // Get the form values
        final formValues = _formKey.currentState!.value;
        
        // Create the report with all fields
        final report = TechnicalReport(
          id: '', // Firestore will auto-generate ID
          title: formValues['title'] ?? '',
          description: formValues['description'] ?? '',
          technicianName: formValues['technicianName'] ?? '',
          reportType: _selectedReportType ?? '',
          siteId: formValues['siteId'] ?? '',
          createdAt: DateTime.now(),
          timestamp: DateTime.now(),
          fuelRemainingBefore: formValues['fuelRemainingBefore'] != null 
              ? double.tryParse(formValues['fuelRemainingBefore'].toString())
              : null,
          fuelAdded: formValues['fuelAdded'] != null
              ? double.tryParse(formValues['fuelAdded'].toString())
              : null,
          genRunningHours: formValues['genRunningHours'] != null
              ? double.tryParse(formValues['genRunningHours'].toString())
              : null,
          plcDisplayPhotoUrl: _plcDisplayPhoto?.path,
          lukuUnitsBefore: formValues['lukuUnitsBefore'] != null
              ? double.tryParse(formValues['lukuUnitsBefore'].toString())
              : null,
          lukuUnitsAfter: formValues['lukuUnitsAfter'] != null
              ? double.tryParse(formValues['lukuUnitsAfter'].toString())
              : null,
          lukuBeforePhotoUrl: _lukuBeforePhoto?.path,
          lukuAfterPhotoUrl: _lukuAfterPhoto?.path,
        );
        
        await DBService.addEntry(report);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _resetForm();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _selectedReportType = null;
      _plcDisplayPhoto = null;
      _lukuBeforePhoto = null;
      _lukuAfterPhoto = null;
    });
    _titleController.clear();
    _descriptionController.clear();
    _technicianNameController.clear();
    _siteIdController.clear();
    _fuelRemainingBeforeController.clear();
    _fuelAddedController.clear();
    _genRunningHoursController.clear();
    _lukuUnitsBeforeController.clear();
    _lukuUnitsAfterController.clear();
  }

  TextEditingController _getControllerForField(String fieldName) {
    switch (fieldName) {
      case 'title': return _titleController;
      case 'description': return _descriptionController;
      case 'technicianName': return _technicianNameController;
      case 'siteId': return _siteIdController;
      case 'fuelRemainingBefore': return _fuelRemainingBeforeController;
      case 'fuelAdded': return _fuelAddedController;
      case 'genRunningHours': return _genRunningHoursController;
      case 'lukuUnitsBefore': return _lukuUnitsBeforeController;
      case 'lukuUnitsAfter': return _lukuUnitsAfterController;
      default: return TextEditingController();
    }
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
              _buildTextField('title', 'Report Title', false),
              _buildTextField('description', 'Description', false),
              _buildTextField('technicianName', 'Name of Technician', true),
              
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
                
                if (_plcDisplayPhoto != null) 
                  _buildPhotoPreview(_plcDisplayPhoto!),
                
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
                
                if (_lukuBeforePhoto != null) 
                  _buildPhotoPreview(_lukuBeforePhoto!),
                
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Picture Before Add Units'),
                  onPressed: () => _takePhoto('luku_before'),
                ),
                
                if (_lukuAfterPhoto != null) 
                  _buildPhotoPreview(_lukuAfterPhoto!),
                
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
        controller: _getControllerForField(name),
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
        controller: _getControllerForField(name),
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

  Widget _buildPhotoPreview(File image) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          image,
          height: 150,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}