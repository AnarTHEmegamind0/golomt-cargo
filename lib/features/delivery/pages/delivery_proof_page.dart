import 'package:core/features/delivery/providers/delivery_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeliveryProofPage extends StatefulWidget {
  const DeliveryProofPage({super.key, required this.orderId});

  final String orderId;

  @override
  State<DeliveryProofPage> createState() => _DeliveryProofPageState();
}

class _DeliveryProofPageState extends State<DeliveryProofPage> {
  bool _submitting = false;
  String? _proofPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Proof')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF424A56), Color(0xFF9CA8B8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(Icons.photo_camera_back_rounded, color: Colors.white, size: 44),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _proofPath == null
                  ? 'No proof captured yet. Tap capture to mock upload.'
                  : 'Captured: $_proofPath',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _proofPath = 'proof_${DateTime.now().millisecondsSinceEpoch}.jpg';
                });
              },
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Capture proof'),
            ),
            const SizedBox(height: 10),
            FilledButton(
                  onPressed: _proofPath == null || _submitting
                  ? null
                  : () async {
                      final provider = context.read<DeliveryProvider>();
                      final navigator = Navigator.of(context);
                      setState(() => _submitting = true);
                      await provider.attachProof(
                        orderId: widget.orderId,
                        proofPath: _proofPath!,
                      );
                      if (!mounted) return;
                      setState(() => _submitting = false);
                      navigator.pop();
                    },
              child: Text(_submitting ? 'Uploading...' : 'Submit proof'),
            ),
          ],
        ),
      ),
    );
  }
}
