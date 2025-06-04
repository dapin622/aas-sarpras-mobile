import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_sarpras11/page/login.dart';
import 'package:project_sarpras11/page/navbar.dart';
import 'package:project_sarpras11/page/pengembalian.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? _defaultHome;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    setState(() {
      if (userId != null) {
        _defaultHome = Navbar();
      } else {
        _defaultHome = LoginPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_defaultHome == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return MaterialApp(
      title: 'Sarpras',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routes: {
        '/login': (context) => LoginPage(),
        '/navbar': (context) => Navbar(),
          '/pengembalian': (context) => PengembalianPage(), 

      },
      home: _defaultHome,
    );
  }
}
