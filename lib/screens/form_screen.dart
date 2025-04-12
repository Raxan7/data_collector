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
  bool _isSubmitting = false;

  // Controllers for all fields
  final TextEditingController _technicianNameController = TextEditingController();
  final TextEditingController _siteIdController = TextEditingController();
  final TextEditingController _fuelRemainingBeforeController = TextEditingController();
  final TextEditingController _fuelAddedController = TextEditingController();
  final TextEditingController _genRunningHoursController = TextEditingController();
  final TextEditingController _lukuUnitsBeforeController = TextEditingController();
  final TextEditingController _lukuUnitsAfterController = TextEditingController();

  Future<void> _takePhoto(String photoType) async {
    try {
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
    } catch (e) {
      _showErrorSnackBar('Failed to take photo: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isSubmitting = true);
      
      try {
        final formValues = _formKey.currentState!.value;
        
        final report = TechnicalReport(
          id: '',
          technicianName: formValues['technicianName']?.toString().trim() ?? '',
          reportType: _selectedReportType ?? '',
          siteId: formValues['siteId']?.toString().trim() ?? '',
          createdAt: DateTime.now(),
          timestamp: DateTime.now(),
          fuelRemainingBefore: formValues['fuelRemainingBefore'] != null 
              ? double.tryParse(formValues['fuelRemainingBefore'].toString().trim())
              : null,
          fuelAdded: formValues['fuelAdded'] != null
              ? double.tryParse(formValues['fuelAdded'].toString().trim())
              : null,
          genRunningHours: formValues['genRunningHours'] != null
              ? double.tryParse(formValues['genRunningHours'].toString().trim())
              : null,
          plcDisplayPhotoUrl: _plcDisplayPhoto?.path,
          lukuUnitsBefore: formValues['lukuUnitsBefore'] != null
              ? double.tryParse(formValues['lukuUnitsBefore'].toString().trim())
              : null,
          lukuUnitsAfter: formValues['lukuUnitsAfter'] != null
              ? double.tryParse(formValues['lukuUnitsAfter'].toString().trim())
              : null,
          lukuBeforePhotoUrl: _lukuBeforePhoto?.path,
          lukuAfterPhotoUrl: _lukuAfterPhoto?.path,
        );
        
        await DBService.addEntry(report);
        
        if (!mounted) return;
        _showSuccessSnackBar('Report submitted successfully!');
        _resetForm();
      } catch (e) {
        if (!mounted) return;
        _showErrorSnackBar('Submission failed: ${e.toString()}');
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField('technicianName', 'Name of Technician', true),
              
              const SizedBox(height: 16),
              FormBuilderDropdown<String>(
                name: 'reportType',
                decoration: const InputDecoration(
                  labelText: 'Select Report Type',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
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
              
              const SizedBox(height: 16),
              _buildTextField('siteId', 'SITE ID', true),
              
              if (_selectedReportType == 'FUEL') ...[
                const SizedBox(height: 24),
                const Text('Fuel Report Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                _buildNumberField('fuelRemainingBefore', 'Fuel Remain Before Adding', true),
                _buildNumberField('fuelAdded', 'Fuel Added', true),
                _buildNumberField('genRunningHours', 'Gen Running Hours', true),
                
                if (_plcDisplayPhoto != null) 
                  _buildPhotoPreview(_plcDisplayPhoto!),
                
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Picture of PLC Display'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () => _takePhoto('plc'),
                ),
              ],
              
              if (_selectedReportType == 'LUKU') ...[
                const SizedBox(height: 24),
                const Text('LUKU Report Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                _buildNumberField('lukuUnitsBefore', 'Luku Remain Units Before Add', true),
                _buildNumberField('lukuUnitsAfter', 'Luku Units After Added', true),
                
                if (_lukuBeforePhoto != null) 
                  _buildPhotoPreview(_lukuBeforePhoto!),
                
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Picture Before Add Units'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () => _takePhoto('luku_before'),
                ),
                
                if (_lukuAfterPhoto != null) 
                  _buildPhotoPreview(_lukuAfterPhoto!),
                
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Picture After Add Units'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.blue,
                  ),
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
                      onPressed: _isSubmitting ? null : _resetForm,
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _isSubmitting ? null : _submitForm,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Submit'),
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
          filled: true,
          fillColor: Colors.white,
        ),
        validator: required
            ? (value) => value == null || value.toString().trim().isEmpty 
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
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: TextInputType.number,
        validator: required
            ? (value) {
                if (value == null || value.toString().trim().isEmpty) return 'This field is required';
                if (double.tryParse(value.toString().trim()) == null) return 'Enter valid number';
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