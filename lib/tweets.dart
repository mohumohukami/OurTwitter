import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ourtwitter/database.dart';
import 'package:ourtwitter/login.dart';
//ツイート
class Tweet {
  final String userName;

  final String userIcon;

  final String text;

  final String createdAt;

  Tweet(this.userName,this.userIcon,this.text,this.createdAt);
}

//モデル　=> ウィジェット　に変換する
Widget modelToWidget(Tweet models) {
  final icon = Container(
    margin: const EdgeInsets.all(20),
    width: 60,
    height: 60,

    child: ClipRRect(
      borderRadius: BorderRadius.circular(30.0),
      child: 
        Image.network(
          '${models.userIcon}',
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child; // 画像が完全にロードされたら表示
            } else {
              return Container(
                width: 50, // 画像サイズと合わせる
                height: 50,
                color: Colors.grey[300], // グレー背景（プレースホルダー）
              );
            }
          },
        )

    )
  );

  final metatext = Container(
    padding: const EdgeInsets.all(6),
    height:40,
    alignment:Alignment.centerLeft,
    child:Text(
      '${models.userName}   ${models.createdAt}',
      style: const TextStyle(color: Colors.grey),
    )
  );

  final text = Container(
    padding: const EdgeInsets.all(8),
    alignment: Alignment.centerLeft,
    child: Text(
      models.text,
      style: const TextStyle(fontWeight: FontWeight.bold)
    )
  );

  return Container(
    padding: const EdgeInsets.all(1),
    decoration: BoxDecoration(
      // 全体を青い枠線で囲む
      border: Border.all(color: Colors.blue),
      color: Colors.white,
    ),
    width: double.infinity,
    // 高さ
    height: 120,
    child: Row(
      children: [
        // アイコン
        icon,
        Expanded(
          child: Column(
            children: [
              // 名前と時間
              metatext,
              // 本文
              text,
            ],
          ),
        ),
      ],
    ),
  );
}
Future<List<Tweet>> poststoData(List<DocumentSnapshot> posts) async {
  List<Tweet> postsListView = [];

  for (int i = 0; i < posts.length; i++) {
    final doc = posts[i];
    final post = doc.data() as Map<String, dynamic>;

    // nullチェックを追加（nullならデフォルト値を設定）
    String image = post['icon'] ?? 'default.png'; // デフォルト画像を設定
    String message = post['content_message'] ?? 'No message';
    String username = post['user'] ?? 'no user';
    DateTime time = (post['createdAt'] as Timestamp).toDate();
    String formattedTime = DateFormat('yyyy/MM/dd HH:mm').format(time);
    String usericon = post['icon'] ?? '';

    postsListView.add(Tweet(username, image, message, formattedTime));
  }
  return postsListView;
}

class Tweets extends ConsumerWidget {
  Tweets({super.key});

  // メッセージコントローラとボタンの処理はそのまま
  final messageController = TextEditingController();

  // 非同期処理をFutureBuilderで行う
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final iconUrl = ref.watch(usericonProvider);
    debugPrint(iconUrl);
    // 非同期でツイートデータを取得
    Future<List> getTweets() async {
      final service = Database();
      final posts = await service.readLatestTweets();
      return await poststoData(posts);
    }

    push() {
      context.push('/post');
    }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('投稿画面'),
          actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // ログアウト処理
              await FirebaseAuth.instance.signOut();
              // ログイン画面に遷移
              context.push('/login');
            },
          ),
        ],
        ),
        body: Center(
          child: FutureBuilder<List>(
            future: getTweets(), // 非同期処理をFutureBuilderで待つ
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // データが読み込まれるまで待機中
              } else if (snapshot.hasError) {
                return Text('エラーが発生しました: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('ツイートがありません');
              } else {
                final postsListView = snapshot.data!;
                return ListView.builder(
                  itemCount: postsListView.length,
                  itemBuilder: (c, i) => modelToWidget(postsListView[i]), // 非同期関数の呼び出し
                );
              }
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: push,
          backgroundColor: Colors.green, // 背景色を緑に変更
          foregroundColor: Colors.white, // アイコンの色を白に変更
          child: Icon(Icons.edit), // アイコンを編集アイコンに変更
        ),
      ),
    );
  }
}
