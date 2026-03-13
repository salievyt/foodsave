import 'dart:math';
import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/core/router/app_router.gr.dart';
import 'package:food_save/core/services/api_service.dart';
import 'package:food_save/core/theme/app_colors.dart';
import 'package:food_save/features/fridge/domain/models/product.dart';
import 'package:food_save/features/fridge/presentation/controllers/fridge_controller.dart';
import 'package:food_save/core/utils/emoji_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/scanner_overlay.dart';
import '../widgets/scanner_controls.dart';

@RoutePage()
class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({super.key});

  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage>
    with TickerProviderStateMixin {
  CameraController? _controller;
  bool _isCameraReady = false;
  bool _isScanning = false;
  bool _isFlashOn = false;

  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;
  late AnimationController _fadeInController;
  late Animation<double> _fadeInAnimation;
  late AnimationController _scanningDotsController;

  @override
  void initState() {
    super.initState();
    _initScanner();
    _setupAnimations();
  }

  void _setupAnimations() {
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );

    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.easeIn,
    );
    _fadeInController.forward();

    _scanningDotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  Future<void> _initScanner() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      try {
        await _controller!.initialize();
        if (mounted) {
          setState(() => _isCameraReady = true);
        }
      } catch (e) {
        debugPrint("Camera init error: $e");
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _scanLineController.dispose();
    _fadeInController.dispose();
    _scanningDotsController.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (!_isCameraReady) return;
    try {
      _isFlashOn = !_isFlashOn;
      await _controller!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
      setState(() {});
    } catch (e) {
      debugPrint("Flash toggle error: $e");
    }
  }

  Future<void> _handleCapture(BuildContext context) async {
    setState(() => _isScanning = true);

    try {
      if (!_isCameraReady || _controller == null) {
        throw Exception("Camera not ready");
      }

      final image = await _controller!.takePicture();
      final response = await ApiService().scanReceipt(image.path);
      final List items = response.data['items'] ?? [];

      final products = items.map((item) {
        final expirationDate = DateTime.parse(item['expiration_date'].toString());
        final category = item['category']?.toString() ?? "Другое";
        return Product(
          id: item['id'].toString(),
          name: item['name'].toString(),
          category: category,
          emoji: EmojiHelper.getEmoji(category),
          purchaseDate: DateTime.now(),
          expiryDate: expirationDate,
        );
      }).toList();

      if (products.isNotEmpty) {
        await ref.read(fridgeControllerProvider.notifier).addProducts(products);
      }

      if (mounted) {
        setState(() => _isScanning = false);
        // ignore: use_build_context_synchronously
        context.router.replace(const FridgeRoute());
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isScanning = false);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сканирования: $e')),
        );
      }
    }
  }

  void _showManualInputSheet(BuildContext context) {
    // Show manual input sheet implementation
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;
        final double scanFrameWidth = screenWidth * 0.82;
        final double scanFrameHeight =
            min(screenHeight * 0.45, scanFrameWidth * 1.2);

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // 1. Camera Preview
              Positioned.fill(
                child: _isCameraReady
                    ? CameraPreview(_controller!)
                    : const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
              ),

              // 2. Dimmed Overlay
              if (_isCameraReady)
                ScanOverlay(
                  scanFrameWidth: scanFrameWidth,
                  scanFrameHeight: scanFrameHeight,
                ),

              // 3. Scan Frame & Animated Line
              if (_isCameraReady && !_isScanning)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: SizedBox(
                      width: scanFrameWidth,
                      height: scanFrameHeight,
                      child: Stack(
                        children: [
                          AnimatedBuilder(
                            animation: _scanLineAnimation,
                            builder: (context, _) => Positioned(
                              top: _scanLineAnimation.value * scanFrameHeight,
                              left: 10,
                              right: 10,
                              child: _buildScanLine(),
                            ),
                          ),
                          const ScanFrameCorners(),
                        ],
                      ),
                    ),
                  ),
                ),

              // 4. Processing UI
              if (_isScanning) _buildProcessingOverlay(),

              // 5. Controls
              ScannerTopBar(
                onBack: () => context.router.maybePop(),
                onFlashToggle: _toggleFlash,
                isFlashOn: _isFlashOn,
              ),

              ScannerBottomPanel(
                isProcessing: _isScanning,
                onManualInput: () => _showManualInputSheet(context),
                onCapture: () => _handleCapture(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScanLine() {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.6),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0),
            AppColors.primary,
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 24),
                const Text(
                  "Анализ чека...",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _scanningDotsController,
                  builder: (context, _) {
                    final dots =
                        '.' * ((_scanningDotsController.value * 3).floor() + 1);
                    return Text(
                      "Пожалуйста, подождите$dots",
                      style: const TextStyle(color: Colors.white70),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
