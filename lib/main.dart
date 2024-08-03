import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signature/signature.dart';
import 'utils.dart';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

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
  var PermissionUtil;

  var Utils;

  @override
  void initState() {
    super.initState();
    PermissionUtil.requestAll();
  }

  // ignore: prefer_final_fields
  GlobalKey _globalKey = GlobalKey();
  Uint8List? signature;
  final controller = SignatureController(
      penColor: Colors.white,
      penStrokeWidth: 3,
      exportPenColor: Colors.red,
      exportBackgroundColor: Colors.black);

  _saveLocalImage() async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData =
        await (image.toByteData(format: ui.ImageByteFormat.png));
    if (byteData != null) {
      final result =
          await ImageGallerySaver.saveImage(byteData.buffer.asUint8List());

      Utils.toast(result.toString());
    }
  }

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
                    setState(() async {
                      if (signature != null) {
                        final status = await Permission.storage.status;
                        if (!status.isGranted ||
                            status.isDenied ||
                            status.isPermanentlyDenied) {
                          await Permission.storage.request();
                        }
                        final time = DateTime.now()
                            .toIso8601String()
                            .replaceAll(".", ":");

                        final result = await ImageGallerySaver.saveImage(
                            signature!,
                            name: 'signature_$time');

                        debugPrint(result.toString());

                        if (result['isSucess']) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Signature Saved")));

                          controller.clear();
                        }
                      }
                    });
                  },
                  child: const Text('export in gallary'),
                ),
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
