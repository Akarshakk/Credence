import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/kyc_service.dart';

class SelfieScreen extends StatefulWidget {
  final VoidCallback onSuccess;

  const SelfieScreen({Key? key, required this.onSuccess}) : super(key: key);

  @override
  _SelfieScreenState createState() => _SelfieScreenState();
}

class _SelfieScreenState extends State<SelfieScreen> {
  final KycService _kycService = KycService();
  XFile? _image;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera, 
      preferredCameraDevice: CameraDevice.front
    );

    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  Future<void> _uploadSelfie() async {
    if (_image == null) return;

    setState(() => _isUploading = true);

    try {
      final result = await _kycService.uploadSelfie(_image!);
      
      // If success (200 OK and no exception), proceed
      widget.onSuccess();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification failed: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Take a Selfie',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Ensure your face is clearly visible and well-lit. Avoid glasses or caps.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 30),
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.grey[200],
              backgroundImage: _image != null 
                 ? (kIsWeb 
                     ? NetworkImage(_image!.path) 
                     : FileImage(File(_image!.path)) as ImageProvider)
                 : null,
              child: _image == null
                  ? Icon(Icons.camera_front, size: 60, color: Colors.grey)
                  : null,
            ),
          ),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: (_image != null && !_isUploading) ? _uploadSelfie : null,
            style: ElevatedButton.styleFrom(
               padding: EdgeInsets.symmetric(vertical: 15),
               backgroundColor: Colors.blue,
            ),
            child: _isUploading
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Verify Face', style: TextStyle(fontSize: 16)),
          ),
           if (_image == null)
            TextButton(
              onPressed: _pickImage,
              child: Text('Open Camera'),
            ),
        ],
      ),
    );
  }
}
