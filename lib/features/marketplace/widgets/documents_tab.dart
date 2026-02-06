import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_mmc_app/features/marketplace/models/property_document.dart';
import 'package:orre_mmc_app/features/marketplace/repositories/document_repository.dart';
import 'package:orre_mmc_app/features/marketplace/screens/pdf_viewer_screen.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';
import 'package:intl/intl.dart';

class DocumentsTab extends ConsumerWidget {
  final String propertyId;

  const DocumentsTab({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(propertyDocumentsProvider(propertyId));

    return documentsAsync.when(
      data: (documents) {
        if (documents.isEmpty) {
          return _buildEmptyState();
        }

        // Group documents by category
        final grouped = <String, List<PropertyDocument>>{};
        for (final doc in documents) {
          grouped.putIfAbsent(doc.documentType, () => []).add(doc);
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...grouped.entries.map((entry) {
                return _buildCategorySection(context, entry.key, entry.value);
              }),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading documents: $error',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            'No Documents Available',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Documents will appear here once uploaded',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String category,
    List<PropertyDocument> docs,
  ) {
    final firstDoc = docs.first;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(firstDoc.categoryIcon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                firstDoc.categoryName.toUpperCase(),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...docs.map((doc) => _buildDocumentCard(context, doc)),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, PropertyDocument doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PDFViewerScreen(pdfUrl: doc.documentUrl, title: doc.title),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${doc.formattedSize} • ${_formatDate(doc.uploadedAt)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
}
