import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:hand_signature/signature.dart';

/// Widget for capturing user signature for legal contracts
class SignaturePad extends StatefulWidget {
  final Function(Uint8List) onSignatureCaptured;
  final VoidCallback? onClear;

  const SignaturePad({
    super.key,
    required this.onSignatureCaptured,
    this.onClear,
  });

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final HandSignatureControl controller = HandSignatureControl(
    threshold: 3.0,
    smoothRatio: 0.65,
    velocityRange: 2.0,
  );

  ValueNotifier<String?> svg = ValueNotifier<String?>(null);
  ValueNotifier<bool> hasSignature = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.isFilled) {
        // Use isFilled instead of hasSignature
        hasSignature.value = true;
      } else {
        hasSignature.value = false;
      }
    });
  }

  Future<void> _captureSignature() async {
    try {
      // Export signature as image (returns ByteData)
      final signature = await controller.toImage(
        color: Colors.white,
        background: Colors.transparent,
        fit: true,
        format: ui.ImageByteFormat.png,
      );

      if (signature != null) {
        final Uint8List pngBytes = signature.buffer.asUint8List();
        widget.onSignatureCaptured(pngBytes);
      }
    } catch (e) {
      debugPrint('Error capturing signature: $e');
    }
  }

  void _clearSignature() {
    controller.clear();
    hasSignature.value = false;
    svg.value = null;
    widget.onClear?.call();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Signature pad container
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: HandSignature(
              control: controller,
              color: Colors.white,
              width: 2.0,
              maxWidth: 4.0,
              type: SignatureDrawType.shape,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Action buttons
        Row(
          children: [
            // Clear button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _clearSignature,
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Done button
            Expanded(
              flex: 2,
              child: ValueListenableBuilder<bool>(
                valueListenable: hasSignature,
                builder: (context, hasSig, _) {
                  return ElevatedButton.icon(
                    onPressed: hasSig ? _captureSignature : null,
                    icon: const Icon(Icons.check),
                    label: const Text('Confirm Signature'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0BDA5E),
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.grey.withValues(
                        alpha: 0.3,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Instruction text
        Text(
          'Sign above to confirm your agreement',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
