import 'package:url_launcher/url_launcher.dart';

class UrlLauncherUtils {
  /// Launch BaseScan contract page
  static Future<void> launchBaseScan(String contractAddress) async {
    final url = Uri.parse('https://basescan.org/address/$contractAddress');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// Launch Azerbaijan State Registry
  static Future<void> launchAzerbaijanRegistry(String propertyId) async {
    final url = Uri.parse('https://e-mulkiyyat.gov.az/property/$propertyId');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// Launch external URL generic
  static Future<void> launchExternalUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// Launch PDF document
  static Future<void> launchPdf(String pdfUrl) async {
    final url = Uri.parse(pdfUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
