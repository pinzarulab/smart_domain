import 'package:flutter/material.dart';
import 'package:smart_domain_example/presentation/demo_page.dart';

void main() {
  runApp(const SmartDomainExampleApp());
}

class SmartDomainExampleApp extends StatelessWidget {
  const SmartDomainExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'smart_domain example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const DemoPage(),
    );
  }
}
