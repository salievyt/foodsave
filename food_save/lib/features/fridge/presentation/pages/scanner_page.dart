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

class _ScannerPageState extends ConsumerState<ScannerPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraReady = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
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
    super.dispose();
  }

  Future<void> _handleCapture(BuildContext context) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() => _isScanning = true);
    
    try {
      final XFile image = await _controller!.takePicture();
      final api = ApiService();
      final response = await api.scanReceipt(image.path);
      
      if (mounted && response.statusCode == 200) {
        final List items = response.data['items'];
        _showResults(context, items);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Чек не распознан или произошла ошибка.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при распознавании чека.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  void _showResults(BuildContext context, List items) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Результаты сканирования",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            ...items.map((item) => ListTile(
              leading: const Icon(Icons.shopping_basket_rounded, color: AppColors.primary),
              title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text("${item['quantity']} ${item['unit']} - Срок ${item['expiration_days_estimated']} дн."),
              trailing: IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                onPressed: () {
                   final product = Product(
                     id: DateTime.now().millisecondsSinceEpoch.toString() + item['name'],
                     name: item['name'],
                     category: "Другое",
                     emoji: "📦",
                     purchaseDate: DateTime.now(),
                     expiryDate: DateTime.now().add(Duration(days: item['expiration_days_estimated'] ?? 7)),
                   );
                   ref.read(fridgeControllerProvider.notifier).addProduct(product);
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${item['name']} добавлен!")));
                },
              ),
            )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () {
                  final List<Product> products = items.map((item) {
                     return Product(
                       id: DateTime.now().millisecondsSinceEpoch.toString() + item['name'],
                       name: item['name'],
                       category: "Другое",
                       emoji: "📦",
                       purchaseDate: DateTime.now(),
                       expiryDate: DateTime.now().add(Duration(days: item['expiration_days_estimated'] ?? 7)),
                     );
                  }).toList();
                  ref.read(fridgeControllerProvider.notifier).addProducts(products);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Все продукты добавлены в холодильник!")));
                },
                child: const Text("Добавить всё в холодильник", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
             child: Container(
              color: Colors.black,
              child: _isCameraReady ? CameraPreview(_controller!) : const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
          ),

          if (_isScanning)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text("Анализирую чек...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildGlassButton(
                          icon: Icons.close_rounded,
                          onPressed: () => context.router.maybePop(),
                        ),
                        const Text(
                          "Сканирование чека",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        _buildGlassButton(
                          icon: Icons.flash_off_rounded,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  Container(
                    height: 400,
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.6), width: 3),
                      borderRadius: BorderRadius.circular(24),
                      color: AppColors.primary.withValues(alpha: 0.05),
                    ),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 2,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.6),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                          ),
                        ),
                        _buildScannerCorner(Alignment.topLeft),
                        _buildScannerCorner(Alignment.topRight),
                        _buildScannerCorner(Alignment.bottomLeft),
                        _buildScannerCorner(Alignment.bottomRight),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  
                  const Flexible(
                    child: Text(
                      "Поместите чек в рамку.\nОн будет отсканирован автоматически.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                    ),
                  ),

                  const Spacer(),

                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => _handleCapture(context),
                          child: Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary, width: 4),
                            ),
                            child: Center(
                              child: Container(
                                height: 60,
                                width: 60,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => _showManualInputDialog(context),
                          child: const Text(
                            "Ввести вручную",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualInputDialog(BuildContext context) {
    final nameController = TextEditingController();
    final daysController = TextEditingController(text: "7");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Добавить вручную"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Название продукта"),
            ),
            TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Срок годности (дней)"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Отмена")),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final product = Product(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  category: "Другое",
                  emoji: "📦",
                  purchaseDate: DateTime.now(),
                  expiryDate: DateTime.now().add(Duration(days: int.tryParse(daysController.text) ?? 7)),
                );
                ref.read(fridgeControllerProvider.notifier).addProduct(product);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Продукт добавлен!")));
              }
            },
            child: const Text("Добавить"),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 48,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onPressed,
          child: Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: Colors.white, size: size * 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildScannerCorner(Alignment alignment) {
    bool isTop = alignment.y < 0;
    bool isLeft = alignment.x < 0;

    return Align(
      alignment: alignment,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
            left: isLeft ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}