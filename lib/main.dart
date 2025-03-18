import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtwitter/firebase_options.dart';
import 'package:ourtwitter/imageprovider.dart';
import 'package:ourtwitter/login.dart';
import 'package:ourtwitter/tweets.dart';
import 'package:ourtwitter/tweet.dart';

class App extends StatelessWidget {
  App({super.key});

  final router = GoRouter(

    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context,state) => Login(),
      ),
      GoRoute(
        path: '/tweets',
        builder: (context,state) => Tweets(),
      ),
      GoRoute(
        path: '/post',
        builder: (context,state) => Post(),
      ),
      // GoRoute(
      //   path: '/image',
      //   builder: (context,state) => UploadImageScreen(),
      // )
    ]
  );
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final myapp = ProviderScope(child: App());
  runApp(myapp);
}
