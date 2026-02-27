import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wtbzdmmuldssamxsiuiv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind0YnpkbW11bGRzc2FteHNpdWl2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAzMTE4NzEsImV4cCI6MjA4NTg4Nzg3MX0.kHAtBQHNyGcTAahs33MeDmkbUiqXgwwHv3ThEyxgGdg',
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Local Service Finder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Start with splash screen
    );
  }
}