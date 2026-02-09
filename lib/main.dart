import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/auth/sign_in_page.dart';
import 'pages/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wtbzdmmuldssamxsiuiv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind0YnpkbW11bGRzc2FteHNpdWl2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAzMTE4NzEsImV4cCI6MjA4NTg4Nzg3MX0.kHAtBQHNyGcTAahs33MeDmkbUiqXgwwHv3ThEyxgGdg',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: user == null ? const SignInPage() : const HomePage(),
    );
  }
}
