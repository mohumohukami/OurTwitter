import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtwitter/database.dart';
//ログイン画面を構築する

// 認証状態を管理するProvider
final errorMessageProvider = StateProvider<String>((ref){return "";});
//アカウント情報(名前)を管理するProvider
final usernameProvider = StateProvider<String>((ref){return "";});
//アカウント情報(アイコン)を管理するProvider
final usericonProvider = StateProvider<String>((ref){return "";});
//アカウント情報(メールアドレス)を管理するProvider
final useremailProvider = StateProvider<String>((ref){return  "";});

class Login extends ConsumerWidget {
  Login({super.key});
  final emailController = TextEditingController();
  final passwordController = TextEditingController();


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final errorMessage = ref.watch(errorMessageProvider);

    //データベースからユーザ情報を入手する
    final db = FirebaseFirestore.instance;
    Future<void> read(String email) async {
      final doc = await db.collection('accounts').doc(email).get();
      final userdata = doc.data();
      //名前の状態管理
      final name = userdata?['username'] ?? 'no name';
      final usernamenotifier = ref.read(usernameProvider.notifier);
      usernamenotifier.state = name;
      //アイコンの状態管理
      String icon = userdata?['icon'] ?? 'no icon';
      final usericonnotifier = ref.read(usericonProvider.notifier);
      usericonnotifier.state = icon;
    }

    //ログイン関数
    Future<void> signInWithEmailAndPassword(String email, String password,BuildContext context,WidgetRef ref) async {
      debugPrint('ログインを試みています...');
      try {
        // Firebase Authenticationでメールアドレスとパスワードでログイン
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        // ログイン成功時の処理
        User? user = userCredential.user; // ログインしたユーザー情報
        if (user != null) {
          debugPrint("ログイン成功！ユーザー情報: ${user.email}");
          final useremailnotifier = ref.read(usericonProvider.notifier);
          useremailnotifier.state = '${user.email}';
          final notifier = ref.read(errorMessageProvider.notifier);
          notifier.state = "";
          read(email);
          context.push('/tweets');
        }
      } on FirebaseAuthException catch (e) {

        final notifier = ref.read(errorMessageProvider.notifier);
        notifier.state = "ログインできませんでした";
        // Firebase Authのエラーをキャッチ
        debugPrint("ログイン失敗: エラーコード=${e.code}, メッセージ=${e.message}");
        if (e.code == 'user-not-found') {
          debugPrint('ユーザーが見つかりませんでした。');
        } else if (e.code == 'wrong-password') {
          debugPrint('パスワードが間違っています。');
        } else if (e.code == 'invalid-email') {
          debugPrint('メールアドレスの形式が不正です。');
        } else {
          debugPrint('その他のエラーが発生しました。');
        }
      } catch (e) {
        final notifier = ref.read(errorMessageProvider.notifier);
        notifier.state = "ログインできませんでした";
        // その他のエラーをキャッチ
        debugPrint('予期しないエラーが発生しました: $e');
      }
    }
    //email入力欄
    debugPrint(errorMessage);
    final email_textfield = TextField(
      controller: emailController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'あなたのメールアドレス',
        hintText: '入力してください',
        //errorText: '名前が長過ぎます。'
      )
    );

    //パスワード入力欄
    final password_textfield = TextField(
      controller: passwordController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'あなたのパスワード',
        hintText: '入力してください',
        //errorText: '名前が長過ぎます。'
      ),
      obscureText: true,
    );

    //ログインボタン
    final login_button = ElevatedButton(
      onPressed: () async{
        await signInWithEmailAndPassword(emailController.text,passwordController.text,context,ref);
      },
      child: Text('ログイン'),
    );

    //エラーテキスト
    final errorText = Text('$errorMessage',style: TextStyle(color: Colors.red));

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('ログイン画面'),
        ),
        body: Center(
          child: Container(
            width:500,
            height: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                email_textfield,
                password_textfield,
                login_button,
                errorText,
              ],
            ),
          ),
        )
      )
    );
  }
}
