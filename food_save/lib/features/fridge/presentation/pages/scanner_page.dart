import 'dart:math';
import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:food_save/core/services/api_service.dart';
import 'package:food_save/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/product.dart';
import '../controllers/fridge_controller.dart';

@RoutePage()
class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({super.key});

  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage>
    with TickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraReady = false;
  bool _isScanning = false;
  bool _isFlashOn = false;

  // Animations
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _fadeInController;
  late Animation<double> _fadeInAnimation;

  late AnimationController _scanningDotsController;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeCamera();
  }

  void _initAnimations() {
    // Scan line animation - moves up and down
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );
    _scanLineController.repeat(reverse: true);

    // Pulse animation for capture button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // Fade in animation for UI elements
    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.easeOut,
    );
    _fadeInController.forward();

    // Scanning dots animation
    _scanningDotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status.isDenied) return;

    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      try {
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isCameraReady = true;
          });
        }
      } catch (e) {
        debugPrint("Camera error: $e");
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _scanLineController.dispose();
    _pulseController.dispose();
    _fadeInController.dispose();
    _scanningDotsController.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.off);
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
      }
      setState(() => _isFlashOn = !_isFlashOn);
    } catch (_) {}
  }

  Future<void> _handleCapture(BuildContext context) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isScanning) return;

    setState(() => _isScanning = true);

    try {
      final XFile image = await _controller!.takePicture();
      final api = ApiService();
      final response = await api.scanReceipt(image.path);

      if (mounted && response.statusCode == 200) {
        final List items = response.data['items'];
        _showResults(context, items);
      } else if (mounted) {
        _showErrorSnackBar('Чек не распознан или произошла ошибка.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Ошибка при распознавании чека.');
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.fresh,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ─── Results Bottom Sheet ───────────────────────────────────
  void _showResults(BuildContext context, List items) {
    final selectedItems = List<bool>.filled(items.length, true);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey.shade50,
                Colors.white,
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFFFF6B6B)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Результаты сканирования",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Найдено ${items.length} продуктов",
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Items list
              Flexible(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 400 + index * 80),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) => Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(opacity: value, child: child),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: selectedItems[index]
                              ? AppColors.primary.withValues(alpha: 0.06)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selectedItems[index]
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.1),
                                  AppColors.primary.withValues(alpha: 0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.shopping_basket_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            item['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            "${item['quantity']} ${item['unit']} · Срок ${item['expiration_days_estimated']} дн.",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Transform.scale(
                            scale: 1.2,
                            child: Checkbox(
                              value: selectedItems[index],
                              onChanged: (val) {
                                setSheetState(() {
                                  selectedItems[index] = val ?? false;
                                });
                              },
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Bottom actions
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        backgroundColor: AppColors.primary,
                      ),
                      onPressed: () {
                        final List<Product> products = [];
                        for (int i = 0; i < items.length; i++) {
                          if (selectedItems[i]) {
                            products.add(Product(
                              id: DateTime.now().millisecondsSinceEpoch.toString() +
                                  items[i]['name'],
                              name: items[i]['name'],
                              category: "Другое",
                              emoji: "📦",
                              purchaseDate: DateTime.now(),
                              expiryDate: DateTime.now().add(Duration(
                                days: items[i]['expiration_days_estimated'] ?? 7,
                              )),
                            ));
                          }
                        }
                        if (products.isNotEmpty) {
                          ref
                              .read(fridgeControllerProvider.notifier)
                              .addProducts(products);
                        }
                        Navigator.pop(context);
                        _showSuccessSnackBar(
                          "Добавлено ${products.length} продуктов в холодильник!",
                        );
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, Color(0xFFFF6B6B)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                "Добавить выбранные (${selectedItems.where((s) => s).length})",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Manual Input Bottom Sheet ──────────────────────────────
  void _showManualInputSheet(BuildContext context) {
    final nameController = TextEditingController();
    final daysController = TextEditingController(text: "7");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: AppColors.accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    "Добавить вручную",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Name field
              TextField(
                controller: nameController,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: "Название продукта",
                  labelStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: const Icon(Icons.fastfood_rounded,
                      color: AppColors.textSecondary, size: 20),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Days field
              TextField(
                controller: daysController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: "Срок годности (дней)",
                  labelStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: const Icon(Icons.calendar_today_rounded,
                      color: AppColors.textSecondary, size: 20),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text(
                          "Отмена",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.isNotEmpty) {
                            final product = Product(
                              id: DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              name: nameController.text,
                              category: "Другое",
                              emoji: "📦",
                              purchaseDate: DateTime.now(),
                              expiryDate: DateTime.now().add(Duration(
                                days:
                                    int.tryParse(daysController.text) ?? 7,
                              )),
                            );
                            ref
                                .read(fridgeControllerProvider.notifier)
                                .addProduct(product);
                            Navigator.pop(context);
                            _showSuccessSnackBar("Продукт добавлен!");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Добавить",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Build
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive scan frame
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;

        // Use more screen for frame but keep it centered
        final double scanFrameWidth = screenWidth * 0.82;
        // Adjust height based on available screen to avoid overflow with buttons
        final double scanFrameHeight = min(screenHeight * 0.45, scanFrameWidth * 1.2);

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Camera preview
              Positioned.fill(
                child: _isCameraReady
                    ? CameraPreview(_controller!)
                    : Container(
                        color: Colors.black,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: AppColors.primary.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Подключение камеры...",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),

              // Dimmed overlay with scan frame cutout
              if (_isCameraReady)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ScanOverlayPainter(
                      scanFrameWidth: scanFrameWidth,
                      scanFrameHeight: scanFrameHeight,
                      borderRadius: 24.0,
                    ),
                  ),
                ),

              // Scanning overlay when processing
              if (_isScanning)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 36,
                            vertical: 28,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 48,
                                height: 48,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Анализирую чек",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              AnimatedBuilder(
                                animation: _scanningDotsController,
                                builder: (context, _) {
                                  final dots = '.' *
                                      ((_scanningDotsController.value * 3).floor() +
                                          1);
                                  return Text(
                                    "Подождите$dots",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Main UI overlay
              Positioned.fill(
                child: SafeArea(
                  child: FadeTransition(
                    opacity: _fadeInAnimation,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // Top bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildGlassButton(
                                icon: Icons.arrow_back_rounded,
                                onPressed: () => context.router.maybePop(),
                              ),
                              // Title with glassmorphism background
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.15),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.document_scanner_rounded,
                                            color: Colors.white, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          "Сканер чеков",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              _buildGlassButton(
                                icon: _isFlashOn
                                    ? Icons.flash_on_rounded
                                    : Icons.flash_off_rounded,
                                onPressed: _toggleFlash,
                                isActive: _isFlashOn,
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Scan frame with animated line
                        SizedBox(
                          width: scanFrameWidth,
                          height: scanFrameHeight,
                          child: Stack(
                            children: [
                              // Animated scan line
                              AnimatedBuilder(
                                animation: _scanLineAnimation,
                                builder: (context, _) => Positioned(
                                  top: _scanLineAnimation.value *
                                      (scanFrameHeight - 4),
                                  left: 16,
                                  right: 16,
                                  child: Container(
                                    height: 3,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primary.withOpacity(0),
                                          AppColors.primary,
                                          AppColors.primary,
                                          AppColors.primary.withOpacity(0),
                                        ],
                                        stops: const [0.0, 0.15, 0.85, 1.0],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withOpacity(0.6),
                                          blurRadius: 16,
                                          spreadRadius: 4,
                                        ),
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withOpacity(0.3),
                                          blurRadius: 30,
                                          spreadRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Corner decorations
                              _buildCorner(Alignment.topLeft),
                              _buildCorner(Alignment.topRight),
                              _buildCorner(Alignment.bottomLeft),
                              _buildCorner(Alignment.bottomRight),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Hint text
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: Colors.white.withOpacity(0.7),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  "Поместите чек в рамку",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Bottom panel with glassmorphism
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(32)),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(40, 24, 40, 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withOpacity(0.12),
                                    Colors.white.withOpacity(0.06),
                                  ],
                                ),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(32)),
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                              ),
                              child: SafeArea(
                                top: false,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Capture button
                                    AnimatedBuilder(
                                      animation: _pulseAnimation,
                                      builder: (context, child) => Transform.scale(
                                        scale: _isScanning
                                            ? 1.0
                                            : _pulseAnimation.value,
                                        child: child,
                                      ),
                                      child: GestureDetector(
                                        onTap: _isScanning
                                            ? null
                                            : () => _handleCapture(context),
                                        child: Container(
                                          height: 80,
                                          width: 80,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: _isScanning
                                                  ? Colors.white
                                                      .withOpacity(0.3)
                                                  : Colors.white
                                                      .withOpacity(0.8),
                                              width: 4,
                                            ),
                                            boxShadow: _isScanning
                                                ? []
                                                : [
                                                    BoxShadow(
                                                      color: AppColors.primary
                                                          .withOpacity(0.4),
                                                      blurRadius: 20,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                          ),
                                          child: Center(
                                            child: Container(
                                              height: 60,
                                              width: 60,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: _isScanning
                                                    ? LinearGradient(
                                                        colors: [
                                                          Colors.grey.shade600,
                                                          Colors.grey.shade700,
                                                        ],
                                                      )
                                                    : const LinearGradient(
                                                        begin: Alignment.topLeft,
                                                        end:
                                                            Alignment.bottomRight,
                                                        colors: [
                                                          AppColors.primary,
                                                          Color(0xFFFF6B6B),
                                                        ],
                                                      ),
                                              ),
                                              child: _isScanning
                                                  ? const Padding(
                                                      padding: EdgeInsets.all(16),
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 3,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : const Icon(
                                                      Icons
                                                          .camera_alt_rounded,
                                                      color: Colors.white,
                                                      size: 28,
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Manual input button
                                    TextButton.icon(
                                      onPressed: () =>
                                          _showManualInputSheet(context),
                                      icon: Icon(
                                        Icons.keyboard_rounded,
                                        color:
                                            Colors.white.withOpacity(0.8),
                                        size: 18,
                                      ),
                                      label: Text(
                                        "Ввести вручную",
                                        style: TextStyle(
                                          color: Colors.white
                                              .withOpacity(0.8),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          side: BorderSide(
                                            color: Colors.white
                                                .withOpacity(0.15),
                                          ),
                                        ),
                                        backgroundColor: Colors.white
                                            .withOpacity(0.08),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Helpers ────────────────────────────────────────────────

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 48,
    bool isActive = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: size * 0.45,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCorner(Alignment alignment) {
    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;
    const cornerSize = 32.0;
    const thickness = 4.0;
    const radius = 12.0;

    return Align(
      alignment: alignment,
      child: SizedBox(
        width: cornerSize,
        height: cornerSize,
        child: CustomPaint(
          painter: _CornerPainter(
            isTop: isTop,
            isLeft: isLeft,
            color: AppColors.primary,
            thickness: thickness,
            radius: radius,
          ),
        ),
      ),
    );
  }
}

// ─── Custom Painters ──────────────────────────────────────────

/// Paints the dimmed overlay around the scan frame
class _ScanOverlayPainter extends CustomPainter {
  final double scanFrameWidth;
  final double scanFrameHeight;
  final double borderRadius;

  _ScanOverlayPainter({
    required this.scanFrameWidth,
    required this.scanFrameHeight,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.55);

    // Calculate frame position (centered horizontally, with vertical offset)
    final frameLeft = (size.width - scanFrameWidth) / 2;
    final frameTop = (size.height - scanFrameHeight) / 2 - 20;

    final outerPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final innerPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(frameLeft, frameTop, scanFrameWidth, scanFrameHeight),
        Radius.circular(borderRadius),
      ));

    final overlayPath =
        Path.combine(PathOperation.difference, outerPath, innerPath);
    canvas.drawPath(overlayPath, paint);
  }

  @override
  bool shouldRepaint(covariant _ScanOverlayPainter oldDelegate) =>
      oldDelegate.scanFrameWidth != scanFrameWidth ||
      oldDelegate.scanFrameHeight != scanFrameHeight;
}

/// Paints rounded corner brackets
class _CornerPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;
  final Color color;
  final double thickness;
  final double radius;

  _CornerPainter({
    required this.isTop,
    required this.isLeft,
    required this.color,
    required this.thickness,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, radius);
      path.quadraticBezierTo(0, 0, radius, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(size.width, size.height);
      path.lineTo(size.width, radius);
      path.quadraticBezierTo(size.width, 0, size.width - radius, 0);
      path.lineTo(0, 0);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height - radius);
      path.quadraticBezierTo(0, size.height, radius, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height - radius);
      path.quadraticBezierTo(
          size.width, size.height, size.width - radius, size.height);
      path.lineTo(0, size.height);
    }

    // Add glow effect
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = thickness + 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) => false;
}