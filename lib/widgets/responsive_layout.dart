// lib/widgets/responsive_layout.dart
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  const ResponsiveLayout({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        // Batasi lebar maksimum konten menjadi 800px
        constraints: const BoxConstraints(maxWidth: 800),
        child: child,
      ),
    );
  }
}