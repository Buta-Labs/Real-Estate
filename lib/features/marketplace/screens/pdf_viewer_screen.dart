import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';

class PDFViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PDFViewerScreen({super.key, required this.pdfUrl, required this.title});

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String? localPath;
  bool isLoading = true;
  String? error;
  int currentPage = 0;
  int totalPages = 0;

  @override
  void initState() {
    super.initState();
    _downloadAndLoadPDF();
  }

  Future<void> _downloadAndLoadPDF() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      final bytes = response.bodyBytes;
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(bytes);

      setState(() {
        localPath = file.path;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load PDF: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.backgroundDark,
        actions: [
          if (totalPages > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '${currentPage + 1} / $totalPages',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    error!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : PDFView(
              filePath: localPath!,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
              pageSnap: true,
              onRender: (pages) {
                setState(() {
                  totalPages = pages ?? 0;
                });
              },
              onPageChanged: (page, total) {
                setState(() {
                  currentPage = page ?? 0;
                });
              },
              onError: (error) {
                setState(() {
                  this.error = error.toString();
                });
              },
            ),
    );
  }
}
