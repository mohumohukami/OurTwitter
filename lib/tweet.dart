import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ourtwitter/database.dart';
import 'package:ourtwitter/login.dart';

class Post extends ConsumerWidget {
  Post({super.key});

  final messageController = TextEditingController();
  

  @override
  Widget build(BuildContext context,WidgetRef ref) {

    //ユーザネーム
    final username = ref.watch(usernameProvider);
    final useremail = ref.watch(useremailProvider);
    final usericon = ref.watch(usericonProvider);
    final message_textfield = TextField(
      controller: messageController,
      decoration: InputDecoration(
              labelText: "入力してください",
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2.0), // 通常時の枠の色
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2.0), // フォーカス時の枠の色
              ),
            ),
    );
    Back(){
      context.pop();
    }
    Input_database(){
      final service = Database();
      service.create(messageController.text,username,usericon);
      //service.readLatestTweets();
      context.push('/tweets');
    }
    final postButton = ElevatedButton(onPressed: Input_database, child: Text('ツイート'));
    return MaterialApp(
      home:Scaffold(
        appBar: AppBar(
          title: Text('ツイート'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Back();
            },
          ),
        ),
        body: Center(
          child:Container(
            width:500,
            height: 300,
            child: Column(
              children:[
                message_textfield,
                postButton
              ]
            )
          )
        ),
      )
    );
  }
}