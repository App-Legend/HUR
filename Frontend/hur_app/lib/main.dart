import 'package:flutter/material.dart';
import 'package:hur_app/ui/pages/main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
<<<<<<< HEAD
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String message = "Loading...";

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: LoginPage());
=======
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HUR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: const MainPage(),
    );
>>>>>>> 8a1c745468a615b1393fb196cda31e98883649be
  }
}
