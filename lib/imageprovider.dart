// import 'dart:typed_data';
// import 'dart:html' as html;
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker_web/image_picker_web.dart';

// class UploadImageScreen extends StatefulWidget {
//   @override
//   _UploadImageScreenState createState() => _UploadImageScreenState();
// }

// class _UploadImageScreenState extends State<UploadImageScreen> {
//   Uint8List? _imageBytes;
//   final FirebaseStorage storage = FirebaseStorage.instance;

//   // 画像を選択（Web用）
//   Future<void> pickImage() async {
//     final Uint8List? bytes = await ImagePickerWeb.getImageAsBytes();
//     if (bytes != null) {
//       setState(() {
//         _imageBytes = bytes;
//       });
//     }
//   }
//   // 画像をFirebase Storageにアップロード
//   Future<void> uploadImage() async {
//     if (_imageBytes == null) return;

//     try {
//       // ファイル名をタイムスタンプ + .png にする
//       String fileName = "${DateTime.now().millisecondsSinceEpoch}.png";
//       Reference ref = storage.ref().child("uploads/$fileName");

//       // Uint8Listをアップロード (MIMEタイプを指定)
//       await ref.putData(
//         _imageBytes!,
//         SettableMetadata(contentType: "image/png"),
//       );

//       // アップロード後の画像URLを取得
//       String downloadURL = await ref.getDownloadURL();
//       print("アップロード完了！URL: $downloadURL");
//     } catch (e) {
//       print("アップロードエラー: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("PNG画像アップロード (Web対応)")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _imageBytes != null
//                 ? Image.memory(_imageBytes!, height: 200)
//                 : Text("画像を選択してください"),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: pickImage,
//               child: Text("画像を選択"),
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: uploadImage,
//               child: Text("アップロード"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
