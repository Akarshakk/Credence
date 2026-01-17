import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/kyc_service.dart';

class DocumentUploadScreen extends StatefulWidget {
  final VoidCallback onSuccess;

  const DocumentUploadScreen({Key? key, required this.onSuccess}) : super(key: key);

  @override
  _DocumentUploadScreenState createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final KycService _kycService = KycService();
  XFile? _image; // Use XFile for cross-platform
  String _selectedType = 'pan';
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  Future<void> _uploadDocument() async {
    if (_image == null) return;

    setState(() => _isUploading = true);

    try {
      final result = await _kycService.uploadDocument(_image!, _selectedType);
      
      bool isValid = result['data']['isValid'];
      if (isValid) {
         widget.onSuccess();
      } else {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Document invalid. Please try again.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Upload ID Document',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('Select document type and upload a clear photo.'),
          SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Document Type'),
            items: [
              DropdownMenuItem(value: 'pan', child: Text('PAN Card')),
              DropdownMenuItem(value: 'aadhaar', child: Text('Aadhaar Card')),
              DropdownMenuItem(value: 'passport', child: Text('Passport')),
              DropdownMenuItem(value: 'driving_license', child: Text('Driving License')),
            ],
            onChanged: (val) => setState(() => _selectedType = val!),
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () => _showPicker(context),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: kIsWeb 
                        ? Image.network(_image!.path, fit: BoxFit.cover)
                        : Image.file(File(_image!.path), fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                        Text('Tap to capture or upload'),
                      ],
                    ),
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: (_image != null && !_isUploading) ? _uploadDocument : null,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Colors.blue,
            ),
            child: _isUploading
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Verify Document', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    );
  }
}


