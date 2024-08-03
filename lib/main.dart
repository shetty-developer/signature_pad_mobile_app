import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
// import 'utils.dart';

// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Signature Pad App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'The Signature Pad App'),
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
  @override
  void initState() {
    super.initState();
  }

  // ignore: prefer_final_fields

  Uint8List? signature;
  final controller = SignatureController(
      penColor: Colors.white,
      penStrokeWidth: 3,
      exportPenColor: Colors.red,
      exportBackgroundColor: Colors.black);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Signature(
              controller: controller,
              width: double.infinity,
              height: 200,
              backgroundColor: Colors.black,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () async => controller.undo(),
                  icon: const Icon(Icons.undo),
                  label: const Text("Undo"),
                ),
                ElevatedButton.icon(
                  onPressed: () async => controller.clear(),
                  icon: const Icon(Icons.clear),
                  label: const Text("Clear"),
                ),
                ElevatedButton.icon(
                  onPressed: () async => controller.redo(),
                  icon: const Icon(Icons.redo),
                  label: const Text("Redo"),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    signature = await controller.toPngBytes();
                    setState(() {});
                  },
                  child: const Text('Save'),
                )
              ],
            )
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
