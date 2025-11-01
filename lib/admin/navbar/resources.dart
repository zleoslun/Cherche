import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  // 📁 Ruta exacta en tu Storage
  final String pdfPath = 'ebook/challenge_21.pdf';

  Future<String> _getPdfUrl() async {
    // Si tu bucket no es el predeterminado, usa:
    // final storage = FirebaseStorage.instanceFor(bucket: 'gs://daily-devotion-7b3b4.appspot.com');
    // return storage.ref(pdfPath).getDownloadURL();

    return FirebaseStorage.instance.ref(pdfPath).getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
        backgroundColor: const Color(0xFF130E6A), // color igual que tu navbar
      ),
      body: FutureBuilder<String>(
        future: _getPdfUrl(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading PDF:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final pdfUrl = snapshot.data!;
          return SfPdfViewer.network(
            pdfUrl,
            canShowScrollHead: true,
            canShowScrollStatus: true,
            enableDoubleTapZooming: true,
          );
        },
      ),
    );
  }
}