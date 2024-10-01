import 'package:custom_tooltip/custom_tooltip.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Tooltip Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Tooltip Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomTooltip(
              tooltip: const Text('This is a basic tooltip'),
              tooltipWidth: 200,
              tooltipHeight: 50,
              child: ElevatedButton(
                child: const Text('Basic Tooltip'),
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 20),
            const CustomTooltip(
              tooltip: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Custom Styled Tooltip'),
                  Divider(),
                  Text('With multiple lines of text'),
                ],
              ),
              tooltipWidth: 200,
              tooltipHeight: 100,
              backgroundColor: Colors.black87,
              borderRadius: 12,
              padding: EdgeInsets.all(12),
              textStyle: TextStyle(color: Colors.white),
              child: Icon(Icons.info, size: 30),
            ),
            const SizedBox(height: 20),
            CustomTooltip(
              tooltip: const Center(child: Text('Gradient Background')),
              tooltipWidth: 200,
              tooltipHeight: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(color: Colors.white, fontSize: 16),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Hover for Gradient Tooltip'),
              ),
            ),
            const SizedBox(height: 20),
            CustomTooltip(
              tooltip: const Text('This tooltip has a longer hover delay'),
              tooltipWidth: 250,
              tooltipHeight: 80,
              hoverShowDelay: const Duration(seconds: 1),
              child: ElevatedButton(
                child: const Text('Delayed Tooltip'),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
