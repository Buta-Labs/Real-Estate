import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Service for generating legally binding investment contracts
/// Assembles a single PDF with conditional sections based on user/property data
class ContractService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Generate a complete investment contract PDF
  /// Returns: ContractResult with PDF bytes, hash, and storage URL
  Future<ContractResult> generateInvestmentContract({
    required String userId,
    required String propertyId,
    required double investmentAmount,
    required Uint8List signatureImage,
    required Map<String, dynamic> userData,
    required Map<String, dynamic> propertyData,
    required String transactionHash,
  }) async {
    // Create PDF document
    final PdfDocument document = PdfDocument();

    try {
      // Add Master Agreement (Pages 1-5)
      await _buildMasterAgreement(
        document,
        userData,
        propertyData,
        investmentAmount,
        transactionHash,
      );

      // Conditionally add Schedule B (Foreign Investors)
      final String userCountry = userData['country'] ?? 'Unknown';
      if (userCountry.toLowerCase() != 'azerbaijan') {
        await _buildScheduleB(document, userData);
      }

      // Conditionally add Annex D (Tier 2 Stay Rights)
      final int tierIndex = propertyData['tierIndex'] ?? 0;
      if (tierIndex == 2 && investmentAmount >= 5000) {
        await _buildAnnexD(document, propertyData, investmentAmount);
      }

      // Add Risk Disclosure (Always)
      await _buildRiskDisclosure(document);

      // Add Signature Page (MUST BE LAST)
      await _buildSignaturePage(document, userData, signatureImage);

      // Save document to bytes
      final List<int> bytes = await document.save();
      final Uint8List pdfBytes = Uint8List.fromList(bytes);
      document.dispose();

      // Calculate PDF hash
      final String pdfHash = _calculatePdfHash(pdfBytes);

      // Upload to Firebase Storage
      final String storageUrl = await _uploadToStorage(
        userId: userId,
        propertyAddress: propertyData['contractAddress'] ?? propertyId,
        pdfBytes: pdfBytes,
      );

      return ContractResult(
        pdfBytes: pdfBytes,
        pdfHash: pdfHash,
        storageUrl: storageUrl,
      );
    } catch (e) {
      document.dispose();
      rethrow;
    }
  }

  /// Build Master Agreement (Pages 1-5)
  Future<void> _buildMasterAgreement(
    PdfDocument document,
    Map<String, dynamic> userData,
    Map<String, dynamic> propertyData,
    double investmentAmount,
    String transactionHash,
  ) async {
    // Page 1: Title and Introduction
    PdfPage page = document.pages.add();
    PdfGraphics graphics = page.graphics;

    // Title
    graphics.drawString(
      'INVESTMENT MASTER AGREEMENT',
      PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold),
      bounds: ui.Rect.fromLTWH(50, 50, page.getClientSize().width - 100, 30),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );

    // Date
    graphics.drawString(
      'Dated: ${DateTime.now().toString().split(' ')[0]}',
      PdfStandardFont(PdfFontFamily.helvetica, 12),
      bounds: ui.Rect.fromLTWH(50, 100, page.getClientSize().width - 100, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );

    // Parties section
    double yOffset = 150;
    final String masterAgreementText =
        '''
THIS INVESTMENT MASTER AGREEMENT ("Agreement") is entered into as of the date set forth above, between:

INVESTOR: ${userData['fullName'] ?? 'N/A'}
ID Number: ${userData['idNumber'] ?? 'N/A'}
Address: ${userData['address'] ?? 'N/A'}
(hereinafter referred to as the "Investor")

AND

ORRE PLATFORM
(hereinafter referred to as the "Platform")

WHEREAS, the Investor desires to invest in tokenized real estate through the Platform;

WHEREAS, the Platform operates a blockchain-based real estate investment platform on Base Sepolia Network;

NOW, THEREFORE, in consideration of the mutual covenants and agreements herein contained, the parties agree as follows:

1. DEFINITIONS

1.1 "Property" means the real estate asset identified as: ${propertyData['title'] ?? 'N/A'}

1.2 "Smart Contract" means the blockchain smart contract deployed at address: ${propertyData['contractAddress'] ?? 'N/A'}

1.3 "Tier Type" means the investment tier classification: ${_getTierName(propertyData['tierIndex'])}

1.4 "Investment Amount" means USD \$${investmentAmount.toStringAsFixed(2)}

1.5 "Transaction Hash" means the blockchain transaction identifier: $transactionHash

2. INVESTMENT TERMS

2.1 The Investor hereby commits to invest the Investment Amount in the Property through the purchase of tokenized fractional ownership interests.

2.2 The investment is recorded on the blockchain via the Smart Contract and is evidenced by the Transaction Hash.

2.3 The Investor acknowledges that this investment is subject to market risks and that returns are not guaranteed.

3. REPRESENTATIONS AND WARRANTIES

3.1 The Investor represents and warrants that:
   (a) They have the legal capacity to enter into this Agreement;
   (b) They have read and understood the Risk Disclosure attached hereto;
   (c) They are investing for their own account and not on behalf of any third party;
   (d) All information provided during registration is accurate and complete.

3.2 The Platform represents and warrants that:
   (a) It is duly organized and validly existing;
   (b) The Smart Contract has been deployed and is functional;
   (c) The Property details are accurate as of the date of this Agreement.

4. INVESTOR RIGHTS

4.1 The Investor shall be entitled to receive returns proportional to their fractional ownership.

4.2 The Investor may transfer their tokenized interests subject to applicable securities laws and Platform rules.

4.3 ${_getTierRights(propertyData['tierIndex'])}

5. GOVERNING LAW

This Agreement shall be governed by and construed in accordance with the laws of Azerbaijan.
''';

    _drawMultiLineText(
      graphics,
      masterAgreementText,
      PdfStandardFont(PdfFontFamily.helvetica, 10),
      50,
      yOffset,
      page.getClientSize().width - 100,
    );
  }

  /// Build Schedule B (Foreign Investors Only)
  Future<void> _buildScheduleB(
    PdfDocument document,
    Map<String, dynamic> userData,
  ) async {
    PdfPage page = document.pages.add();
    PdfGraphics graphics = page.graphics;

    graphics.drawString(
      'SCHEDULE B',
      PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold),
      bounds: ui.Rect.fromLTWH(50, 50, page.getClientSize().width - 100, 30),
    );

    graphics.drawString(
      'FOREIGN INVESTOR PROVISIONS',
      PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold),
      bounds: ui.Rect.fromLTWH(50, 80, page.getClientSize().width - 100, 25),
    );

    final String scheduleBText =
        '''
Applicable to: ${userData['fullName'] ?? 'N/A'}
Country of Residence: ${userData['country'] ?? 'N/A'}

1. TAX WITHHOLDING

1.1 The Investor acknowledges that as a non-resident of Azerbaijan, their investment returns may be subject to withholding tax in accordance with Azerbaijani tax law and applicable tax treaties.

1.2 The Platform reserves the right to withhold applicable taxes from distributions to foreign investors.

2. COMPLIANCE WITH LOCAL LAWS

2.1 The Investor represents that their participation in this investment does not violate any laws or regulations of their country of residence.

2.2 The Investor is solely responsible for compliance with all applicable reporting requirements in their jurisdiction.

3. CURRENCY CONVERSION

3.1 All payments shall be made in USD. The Investor acknowledges that currency conversion risks are borne by the Investor.

4. DISPUTE RESOLUTION

4.1 Any disputes arising under this Agreement shall be resolved through arbitration in Baku, Azerbaijan, in accordance with the rules of the Baku Arbitration Court.

4.2 The Investor hereby consents to the jurisdiction of Azerbaijani courts for enforcement of arbitral awards.

5. ADDITIONAL REPRESENTATIONS

5.1 The Investor confirms that they have obtained all necessary approvals or consents required under the laws of their country for making this investment.

5.2 The Investor acknowledges that the Platform makes no representations regarding the tax treatment of this investment in the Investor's jurisdiction.
''';

    _drawMultiLineText(
      graphics,
      scheduleBText,
      PdfStandardFont(PdfFontFamily.helvetica, 10),
      50,
      120,
      page.getClientSize().width - 100,
    );
  }

  /// Build Annex D (Tier 2 Stay Rights)
  Future<void> _buildAnnexD(
    PdfDocument document,
    Map<String, dynamic> propertyData,
    double investmentAmount,
  ) async {
    PdfPage page = document.pages.add();
    PdfGraphics graphics = page.graphics;

    graphics.drawString(
      'ANNEX D',
      PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold),
      bounds: ui.Rect.fromLTWH(50, 50, page.getClientSize().width - 100, 30),
    );

    graphics.drawString(
      'TIER 2 STAY RIGHTS AGREEMENT',
      PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold),
      bounds: ui.Rect.fromLTWH(50, 80, page.getClientSize().width - 100, 25),
    );

    final String annexDText =
        '''
Property: ${propertyData['title'] ?? 'N/A'}
Investment Amount: USD \$${investmentAmount.toStringAsFixed(2)}

IMPORTANT NOTICE: NATURE OF STAY RIGHTS

The Investor acknowledges and agrees that the stay rights granted under this Tier 2 investment are:

1. REVOCABLE PERSONAL LICENSE

1.1 The stay rights constitute a revocable, non-transferable personal license to occupy the Property for specified periods.

1.2 These rights DO NOT constitute:
   (a) Ownership or co-ownership of the physical real estate;
   (b) A timeshare interest as defined under any applicable timeshare legislation;
   (c) A lease or tenancy agreement;
   (d) Any property right, lien, or encumbrance on the Property.

2. TERMS OF STAY RIGHTS

2.1 The Investor is entitled to stay at the Property for a maximum of ${_calculateStayNights(investmentAmount)} nights per year, subject to availability and booking policies.

2.2 Stay rights must be booked in advance through the Platform's reservation system.

2.3 All stays are subject to the Property's house rules and occupancy standards.

3. REVOCABILITY

3.1 The Platform reserves the right to revoke or modify stay rights in the following circumstances:
   (a) Material breach of this Agreement by the Investor;
   (b) Damage to or misuse of the Property;
   (c) Change in Property ownership or operational status;
   (d) Force majeure events rendering the Property unavailable.

3.2 In the event of revocation, the Investor's financial interest (tokenized ownership) remains unaffected, but physical access rights are terminated.

4. NO GUARANTEED AVAILABILITY

4.1 The Investor acknowledges that stay rights are subject to availability and do not guarantee access to the Property at any specific time.

4.2 Blackout dates may apply during peak seasons or maintenance periods.

5. TERMINATION

5.1 Stay rights terminate automatically upon:
   (a) Sale or transfer of the Investor's tokenized interests;
   (b) Liquidation or sale of the Property;
   (c) Expiration or termination of this Agreement.

6. INVESTOR ACKNOWLEDGMENT

By signing this Agreement, the Investor expressly acknowledges that they have read, understood, and agreed to the terms of this Annex D, and that they understand the limited and revocable nature of the stay rights.
''';

    _drawMultiLineText(
      graphics,
      annexDText,
      PdfStandardFont(PdfFontFamily.helvetica, 10),
      50,
      120,
      page.getClientSize().width - 100,
    );
  }

  /// Build Risk Disclosure (Always included)
  Future<void> _buildRiskDisclosure(PdfDocument document) async {
    PdfPage page = document.pages.add();
    PdfGraphics graphics = page.graphics;

    graphics.drawString(
      'RISK DISCLOSURE STATEMENT',
      PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold),
      bounds: ui.Rect.fromLTWH(50, 50, page.getClientSize().width - 100, 30),
    );

    final String riskText = '''
IMPORTANT: Please read this Risk Disclosure Statement carefully before proceeding with your investment.

1. GENERAL INVESTMENT RISKS

Real estate investments carry inherent risks. The value of your investment may fluctuate, and you may lose some or all of your invested capital. Past performance is not indicative of future results.

2. MARKET RISKS

(a) Property values may decrease due to economic conditions, market trends, or local factors;
(b) Rental income and yields are not guaranteed and may vary;
(c) Liquidity may be limited - you may not be able to sell your tokens quickly or at a desired price.

3. BLOCKCHAIN AND TECHNOLOGY RISKS

(a) Smart contract vulnerabilities could result in loss of funds;
(b) Network congestion or technical failures may delay transactions;
(c) Blockchain technology is still emerging and subject to regulatory changes;
(d) Loss of private keys or wallet access may result in permanent loss of tokens.

4. REGULATORY RISKS

(a) Securities regulations may change and impact the trading or classification of tokens;
(b) Tax treatment of tokenized real estate is uncertain and may change;
(c) Cross-border investments may be subject to additional restrictions.

5. OPERATIONAL RISKS

(a) The Platform may cease operations or change its business model;
(b) Property management may be suboptimal, affecting returns;
(c) Costs may exceed projections, reducing profitability.

6. TIER-SPECIFIC RISKS

For Tier 2 Investments:
(a) Stay rights are revocable and not guaranteed;
(b) Availability may be limited during peak periods;
(c) Property may be sold or repurposed, terminating stay rights.

7. NO GUARANTEES

The Platform makes no guarantees regarding:
(a) The future value of tokens or property;
(b) The amount or timing of distributions;
(c) The availability or quality of stay rights (if applicable);
(d) The ability to liquidate your investment.

8. SUITABILITY

This investment may not be suitable for all investors. You should:
(a) Assess your own risk tolerance and investment objectives;
(b) Consult with financial, legal, and tax advisors;
(c) Only invest funds that you can afford to lose.

9. ACKNOWLEDGMENT

By proceeding with this investment, you acknowledge that:
(a) You have read and understood this Risk Disclosure Statement;
(b) You accept the risks associated with this investment;
(c) You have had the opportunity to ask questions and seek professional advice;
(d) No representations or warranties have been made beyond those in this Agreement.
''';

    _drawMultiLineText(
      graphics,
      riskText,
      PdfStandardFont(PdfFontFamily.helvetica, 9),
      50,
      90,
      page.getClientSize().width - 100,
    );
  }

  /// Build Signature Page (MUST BE LAST PAGE)
  Future<void> _buildSignaturePage(
    PdfDocument document,
    Map<String, dynamic> userData,
    Uint8List signatureImage,
  ) async {
    PdfPage page = document.pages.add();
    PdfGraphics graphics = page.graphics;

    graphics.drawString(
      'SIGNATURE PAGE',
      PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold),
      bounds: ui.Rect.fromLTWH(50, 50, page.getClientSize().width - 100, 30),
    );

    final String signatureText =
        '''
IN WITNESS WHEREOF, the parties have executed this Investment Master Agreement as of the date first written above.

INVESTOR:

Name: ${userData['fullName'] ?? 'N/A'}

Digital Signature:
''';

    double yOffset = 100;
    _drawMultiLineText(
      graphics,
      signatureText,
      PdfStandardFont(PdfFontFamily.helvetica, 11),
      50,
      yOffset,
      page.getClientSize().width - 100,
    );

    // Draw signature image
    final PdfBitmap signatureBitmap = PdfBitmap(signatureImage);
    graphics.drawImage(
      signatureBitmap,
      ui.Rect.fromLTWH(50, yOffset + 80, 200, 100),
    );

    // Add signature timestamp
    graphics.drawString(
      'Signed electronically on: ${DateTime.now().toString()}',
      PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.italic),
      bounds: ui.Rect.fromLTWH(
        50,
        yOffset + 200,
        page.getClientSize().width - 100,
        20,
      ),
    );

    // Add legal notice
    final String legalNotice = '''
This document has been signed electronically and is legally binding. The blockchain transaction hash serves as proof of execution and cannot be altered.
''';

    _drawMultiLineText(
      graphics,
      legalNotice,
      PdfStandardFont(PdfFontFamily.helvetica, 8, style: PdfFontStyle.italic),
      50,
      yOffset + 240,
      page.getClientSize().width - 100,
    );
  }

  /// Helper: Draw multi-line text
  void _drawMultiLineText(
    PdfGraphics graphics,
    String text,
    PdfFont font,
    double x,
    double y,
    double width,
  ) {
    graphics.drawString(
      text,
      font,
      bounds: ui.Rect.fromLTWH(x, y, width, 1000),
      format: PdfStringFormat(lineSpacing: 5),
    );
  }

  /// Helper: Calculate PDF SHA-256 hash
  String _calculatePdfHash(Uint8List pdfBytes) {
    final digest = sha256.convert(pdfBytes);
    return digest.toString();
  }

  /// Helper: Upload PDF to Firebase Storage
  Future<String> _uploadToStorage({
    required String userId,
    required String propertyAddress,
    required Uint8List pdfBytes,
  }) async {
    try {
      final String fileName =
          '${propertyAddress}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final Reference ref = _storage.ref().child(
        'users/$userId/contracts/$fileName',
      );

      await ref.putData(
        pdfBytes,
        SettableMetadata(contentType: 'application/pdf'),
      );

      final String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload contract to storage: $e');
    }
  }

  /// Helper: Get tier display name
  String _getTierName(int? tierIndex) {
    switch (tierIndex) {
      case 0:
        return 'Tier 0 - Rental Income';
      case 1:
        return 'Tier 1 - Growth Appreciation';
      case 2:
        return 'Tier 2 - Owner-Stay Rights';
      default:
        return 'Unknown Tier';
    }
  }

  /// Helper: Get tier-specific rights
  String _getTierRights(int? tierIndex) {
    switch (tierIndex) {
      case 0:
        return 'Tier 0 investors are entitled to receive rental income distributions based on their proportional ownership.';
      case 1:
        return 'Tier 1 investors participate in capital appreciation and may receive returns upon property sale or refinancing.';
      case 2:
        return 'Tier 2 investors receive stay rights as detailed in Annex D, in addition to financial returns.';
      default:
        return 'Standard investor rights apply.';
    }
  }

  /// Helper: Calculate stay nights based on investment amount
  int _calculateStayNights(double investmentAmount) {
    // Same logic as mobile app
    if (investmentAmount >= 15000) return 21;
    if (investmentAmount >= 10000) return 14;
    if (investmentAmount >= 5000) return 7;
    return 0;
  }
}

/// Result of contract generation
class ContractResult {
  final Uint8List pdfBytes;
  final String pdfHash;
  final String storageUrl;

  ContractResult({
    required this.pdfBytes,
    required this.pdfHash,
    required this.storageUrl,
  });
}
