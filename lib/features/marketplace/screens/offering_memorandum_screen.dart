import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';

class OfferingMemorandumScreen extends StatefulWidget {
  final int tierIndex;

  const OfferingMemorandumScreen({super.key, required this.tierIndex});

  @override
  State<OfferingMemorandumScreen> createState() =>
      _OfferingMemorandumScreenState();
}

class _OfferingMemorandumScreenState extends State<OfferingMemorandumScreen> {
  String _content = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      // Load base OM
      final baseContent = await rootBundle.loadString(
        'lib/assets/docs/offering_memorandum_base.md',
      );

      // Load tier-specific addendum
      String tierContent = '';
      switch (widget.tierIndex) {
        case 0: // Rental
          tierContent = await rootBundle.loadString(
            'lib/assets/docs/offering_memorandum_rental.md',
          );
          break;
        case 1: // Growth
          tierContent = await rootBundle.loadString(
            'lib/assets/docs/offering_memorandum_growth.md',
          );
          break;
        case 2: // Owner-Stay
          tierContent = await rootBundle.loadString(
            'lib/assets/docs/offering_memorandum_stay.md',
          );
          break;
      }

      setState(() {
        _content = '$baseContent\n\n---\n\n$tierContent';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _content = '# Error Loading Document\n\nPlease try again later.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Offering Memorandum',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: [
                Expanded(
                  child: Markdown(
                    data: _content,
                    styleSheet: MarkdownStyleSheet(
                      h1: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      h2: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      h3: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      p: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 14,
                        height: 1.6,
                      ),
                      listBullet: const TextStyle(color: AppColors.primary),
                      code: TextStyle(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        color: AppColors.primary,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      blockquote: TextStyle(
                        color: Colors.grey[400],
                        fontStyle: FontStyle.italic,
                      ),
                      blockquoteDecoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: AppColors.primary, width: 4),
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.backgroundDark,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'I Acknowledge',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
