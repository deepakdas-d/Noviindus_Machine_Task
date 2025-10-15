import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:noviindus/providers/add_feed_provider.dart';
import 'package:noviindus/providers/category_provider.dart';
import 'package:noviindus/providers/home_provider.dart';
import 'package:noviindus/screens/add_feed.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login.dart';
import 'screens/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _initializeAuth(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loadUser(); // Load saved user/token
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeAuth(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // Show loading while checking saved login
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final authProvider = Provider.of<AuthProvider>(context);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Noviindus Auth Demo',
          theme: ThemeData.dark(),
          home: authProvider.isLoggedIn ? const Home() : const Login(),
          routes: {
            '/login': (context) => const Login(),
            '/home': (context) => const Home(),
            '/addfeed': (context) => const AddFeed(),
          },
          onUnknownRoute: (settings) =>
              MaterialPageRoute(builder: (context) => const Login()),
        );
      },
    );
  }
}
