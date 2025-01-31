// import 'package:authenticationapp/providers/imageuploadscreen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:firebase_auth/firebase_auth.dart';


// import 'loginpage.dart';

// class ImageUploadScreen extends StatelessWidget {
//   final String noteId;
//   final String userEmail;

//   const ImageUploadScreen({
//     Key? key,
//     required this.noteId,
//     required this.userEmail,
//   }) : super(key: key);

//   void _logout(BuildContext context) async {
//     bool confirmLogout = await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("Logout", style: GoogleFonts.poppins()),
//         content: Text("Are you sure you want to logout?", style: GoogleFonts.poppins()),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.black)),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: Text("Logout", style: GoogleFonts.poppins(color: Colors.red)),
//           ),
//         ],
//       ),
//     );

//     if (confirmLogout) {
//       await FirebaseAuth.instance.signOut();
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => LogIn()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => ImageUploadProvider(),
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('Upload Image', style: GoogleFonts.poppins()),
//           flexibleSpace: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.orange.shade400, Colors.deepOrange.shade400],
//               ),
//             ),
//           ),
//           actions: [
//             IconButton(
//               icon: Icon(Icons.logout),
//               onPressed: () => _logout(context),
//             ),
//           ],
//         ),
//         body: Consumer<ImageUploadProvider>(
//           builder: (context, provider, child) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   provider.image == null
//                       ? Text(
//                           'No image selected',
//                           style: GoogleFonts.poppins(),
//                         )
//                       : Image.file(
//                           provider.image!,
//                           height: 200,
//                           width: 200,
//                           fit: BoxFit.cover,
//                         ),
//                   const SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       ElevatedButton.icon(
//                         icon: const Icon(Icons.camera),
//                         label: Text('Camera', style: GoogleFonts.poppins()),
//                         onPressed: () => provider.pickImage(ImageSource.camera),
//                         style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade400),
//                       ),
//                       const SizedBox(width: 20),
//                       ElevatedButton.icon(
//                         icon: const Icon(Icons.photo),
//                         label: Text('Gallery', style: GoogleFonts.poppins()),
//                         onPressed: () => provider.pickImage(ImageSource.gallery),
//                         style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange.shade400),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   provider.image != null
//                       ? ElevatedButton(
//                           onPressed: provider.isUploading
//                               ? null
//                               : () async {
//                                   bool success = await provider.uploadImageToS3(
//                                     noteId: noteId,
//                                     userEmail: userEmail,
//                                   );
//                                   if (success) {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text(
//                                           'Image uploaded successfully!',
//                                           style: GoogleFonts.poppins(color: Colors.white),
//                                         ),
//                                         backgroundColor: Colors.green,
//                                       ),
//                                     );
//                                     Navigator.of(context).popUntil((route) => route.isFirst);
//                                   } else {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text(
//                                           'Failed to upload image',
//                                           style: GoogleFonts.poppins(color: Colors.white),
//                                         ),
//                                         backgroundColor: Colors.red,
//                                       ),
//                                     );
//                                   }
//                                 },
//                           style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                           child: provider.isUploading
//                               ? const CircularProgressIndicator(color: Colors.white)
//                               : Text(
//                                   'Upload Image',
//                                   style: GoogleFonts.poppins(color: Colors.white),
//                                 ),
//                         )
//                       : Container(),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }