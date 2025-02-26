import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_drop/screens/app.dart';
import 'package:quick_drop/components/appbar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const MyHomePage(title: 'Flutter Demo')
        ),
        GoRoute(
          path: '/app',
          builder: (context, state) => AppPage(),
        )
      ]
    );

    return MaterialApp.router(
      routerConfig: router,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue)
      )
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void startApp() {
    context.go('/app');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Quick Drop', style: TextStyle(fontSize: 32)),
            TextButton(
              onPressed: startApp,
              child: const Text('はじめる')
            )
          ],
        ),
      )
    );
  }
}
