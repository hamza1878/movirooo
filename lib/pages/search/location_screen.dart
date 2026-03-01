import 'package:flutter/material.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter Location"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: TextField(
          decoration: const InputDecoration(
            hintText: "Type location",
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            print(value);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}