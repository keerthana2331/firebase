// import 'dart:io';
// import 'package:authenticationapp/services/aws.dart';
// import 'package:flutter/foundation.dart';
// import 'package:image_picker/image_picker.dart';


// class ImageUploadProvider with ChangeNotifier {
//   final AWSS3Service _s3Service = AWSS3Service();
//   File? _image;
//   bool _isUploading = false;
//   String? _uploadedImageUrl;
//   final ImagePicker _picker = ImagePicker();

//   File? get image => _image;
//   bool get isUploading => _isUploading;
//   String? get uploadedImageUrl => _uploadedImageUrl;

//   Future<void> pickImage(ImageSource source) async {
//     final pickedFile = await _picker.pickImage(source: source);
    
//     if (pickedFile != null) {
//       _image = File(pickedFile.path);
//       notifyListeners();
//     }
//   }

//   Future<bool> uploadImageToS3({
//     required String noteId,
//     required String userEmail,
//   }) async {
//     if (_image == null) return false;

//     _isUploading = true;
//     notifyListeners();

//     try {
//       _uploadedImageUrl = await _s3Service.uploadFile(_image!, noteId);
//       _isUploading = false;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _isUploading = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   void resetImage() {
//     _image = null;
//     _uploadedImageUrl = null;
//     notifyListeners();
//   }
// }