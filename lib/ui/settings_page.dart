import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/storage/prefs.dart';
import '../game/rendering/sprites.dart';
import 'dart:ui' as ui;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Color _selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentColor();
    });
  }

  void _loadCurrentColor() {
    final prefsService = context.read<PreferencesService>();
    setState(() {
      _selectedColor = Color(int.parse(prefsService.jacketColor));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Skier Jacket Color',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          // Skier preview
          Container(
            width: 100,
            height: 160,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FutureBuilder<ui.Image?>(
              future: _getSkierImage(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return CustomPaint(
                    painter: _SkierPreviewPainter(
                      image: snapshot.data!,
                      color: _selectedColor,
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          const SizedBox(height: 24),
          // Color picker
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _ColorChip(Colors.blue, _selectedColor, (color) => _setColor(color)),
                _ColorChip(Colors.red, _selectedColor, (color) => _setColor(color)),
                _ColorChip(Colors.green, _selectedColor, (color) => _setColor(color)),
                _ColorChip(Colors.orange, _selectedColor, (color) => _setColor(color)),
                _ColorChip(Colors.purple, _selectedColor, (color) => _setColor(color)),
                _ColorChip(Colors.pink, _selectedColor, (color) => _setColor(color)),
                _ColorChip(Colors.teal, _selectedColor, (color) => _setColor(color)),
                _ColorChip(Colors.amber, _selectedColor, (color) => _setColor(color)),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                context.read<PreferencesService>().setJacketColor(
                      _selectedColor.value.toString(),
                    );
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  Future<ui.Image?> _getSkierImage() async {
    await SpriteCache().loadSprites();
    return SpriteCache().skierImage;
  }

  void _setColor(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }
}

class _ColorChip extends StatelessWidget {
  final Color color;
  final Color selectedColor;
  final Function(Color) onTap;

  const _ColorChip(this.color, this.selectedColor, this.onTap);

  @override
  Widget build(BuildContext context) {
    final isSelected = color == selectedColor;
    return GestureDetector(
      onTap: () => onTap(color),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }
}

class _SkierPreviewPainter extends CustomPainter {
  final ui.Image image;
  final Color color;

  _SkierPreviewPainter({required this.image, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 - 25, size.height / 2 - 40);
    canvas.scale(50 / image.width, 80 / image.height);
    
    final paint = Paint()
      ..colorFilter = ColorFilter.mode(color, BlendMode.modulate);
    canvas.drawImage(image, Offset.zero, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SkierPreviewPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

