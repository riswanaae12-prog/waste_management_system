import 'package:flutter/material.dart';

class LocateScreen extends StatefulWidget {
  const LocateScreen({Key? key}) : super(key: key);

  @override
  State<LocateScreen> createState() => _LocateScreenState();
}

class _LocateScreenState extends State<LocateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locate'),
        backgroundColor: Colors.green.shade700,
      ),
      body: const Center(
        child: Text('Locate Screen'),
      ),
    );
  }
}
