import 'package:flutter/material.dart';

import 'design/theme.dart';
import 'design/tokens.dart';
import 'gallery/gallery_page.dart';

void main() => runApp(const EvaporateApp());

class EvaporateApp extends StatefulWidget {
  const EvaporateApp({super.key});

  @override
  State<EvaporateApp> createState() => _EvaporateAppState();
}

class _EvaporateAppState extends State<EvaporateApp> {
  EvSkin _skin = EvSkin.magma;
  EvGeometry _geometry = EvGeometry.tight;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Evaporate',
      debugShowCheckedModeBanner: false,
      theme: buildEvTheme(skin: _skin, geometry: _geometry),
      // Тема одна — тёмная, по требованию продукта.
      themeAnimationDuration: EvMotion.screen,
      themeAnimationCurve: EvMotion.easeOut,
      home: GalleryPage(
        skin: _skin,
        geometry: _geometry,
        onSkin: (s) => setState(() => _skin = s),
        onGeometry: (g) => setState(() => _geometry = g),
      ),
    );
  }
}
