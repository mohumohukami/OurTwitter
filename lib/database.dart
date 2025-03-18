import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

class Database{
  final db = FirebaseFirestore.instance;

  Future<void> create(String content,String username,String icon) async {
    DateTime now = DateTime.now();

    //String formattedDate = DateFormat('yyyy/MM/dd HH:mm:ss').format(now);
    await db.collection('tweets').doc().set(
      {
        'user': username,
        'createdAt': now,
        'content_message': content,
        'content_image': 'icon1.png',
        'icon': icon,
      },
    ).catchError((error) {
      print("Firestore書き込みエラー: $error");
    });
  }

  Future<String> getImageUrl(String fileName) async {
    try {
      Reference ref = FirebaseStorage.instance.ref().child('uploads/$fileName');
      String url = await ref.getDownloadURL();
      debugPrint(url);
      return url;
    } catch (e) {
      print("画像取得エラー: $e");
      return "";
    }
  }
  Future<List<DocumentSnapshot>> readLatestTweets() async {
    final snapshot = await db.collection('tweets')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();
    snapshot.docs.forEach((doc) {
      //debugPrint('Tweet ID: ${doc.id}, Data: ${doc.data()}');
    });
    return snapshot.docs;
  }
}
