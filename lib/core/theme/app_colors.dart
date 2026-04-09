// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

/* =========================
   BRAND COLORS (PLANT THEME)
   ========================= */
const Color kPlantGreen = Color(0xFF2E7D32);       // Hijau natural untuk tanaman
const Color kPlantGreenLight = Color(0xFF4CAF50);  // Hijau lebih terang
const Color kPlantGreenDark = Color(0xFF1B5E20);   // Hijau lebih gelap
const Color kPlantAccent = Color(0xFF8BC34A);      // Hijau cerah sebagai aksen

// Warna Bunga — pink/rose yang lembut dan elegan
const Color kFlowerPink = Color(0xFFE91E63);       // Pink utama untuk bunga
const Color kFlowerPinkLight = Color(0xFFF48FB1);  // Pink terang
const Color kFlowerPinkDark = Color(0xFFC2185B);   // Pink gelap
const Color kFlowerRose = Color(0xFFFF8A80);       // Aksen rose

const Color kDelcomYellow = Color(0xFFFFC107);
const Color kDelcomYellowSoft = Color(0xFFFFE082);

/* =========================
   LIGHT THEME (PLANT + BUNGA)
   ========================= */
const Color kLightPrimary = kPlantGreen;
const Color kLightOnPrimary = Colors.white;
const Color kLightPrimaryContainer = Color(0xFFC8E6C9);
const Color kLightOnPrimaryContainer = Color(0xFF002107);

// Secondary = warna bunga (pink/rose)
const Color kLightSecondary = kFlowerPink;
const Color kLightOnSecondary = Colors.white;
const Color kLightSecondaryContainer = Color(0xFFFCE4EC);
const Color kLightOnSecondaryContainer = Color(0xFF3E0020);

const Color kLightTertiary = kPlantGreenDark;
const Color kLightOnTertiary = Colors.white;

const Color kLightError = Color(0xFFBA1A1A);
const Color kLightOnError = Colors.white;
const Color kLightErrorContainer = Color(0xFFFFDAD6);
const Color kLightOnErrorContainer = Color(0xFF410002);

const Color kLightBackground = Color(0xFFF8FBF8);
const Color kLightOnBackground = Color(0xFF121212);
const Color kLightSurface = Color(0xFFFAFFFA);
const Color kLightOnSurface = Color(0xFF121212);
const Color kLightSurfaceVariant = Color(0xFFE3EBE3);
const Color kLightOnSurfaceVariant = Color(0xFF444944);
const Color kLightOutline = Color(0xFF747C74);

/* =========================
   DARK THEME (PLANT + BUNGA)
   ========================= */
const Color kDarkPrimary = kPlantGreenLight;
const Color kDarkOnPrimary = Colors.black;
const Color kDarkPrimaryContainer = Color(0xFF1A4F1D);
const Color kDarkOnPrimaryContainer = Color(0xFFC8E6C9);

// Secondary dark = pink terang agar kontras di latar gelap
const Color kDarkSecondary = kFlowerPinkLight;
const Color kDarkOnSecondary = Color(0xFF3E0020);
const Color kDarkSecondaryContainer = Color(0xFF5B1135);
const Color kDarkOnSecondaryContainer = Color(0xFFFCE4EC);

const Color kDarkTertiary = kPlantAccent;
const Color kDarkOnTertiary = Colors.black;

const Color kDarkError = Color(0xFFFFB4AB);
const Color kDarkOnError = Color(0xFF690005);
const Color kDarkErrorContainer = Color(0xFF93000A);
const Color kDarkOnErrorContainer = Color(0xFFFFDAD6);

const Color kDarkBackground = Color(0xFF0E120E);
const Color kDarkOnBackground = Color(0xFFEAEAEA);
const Color kDarkSurface = Color(0xFF121812);
const Color kDarkOnSurface = Color(0xFFEAEAEA);
const Color kDarkSurfaceVariant = Color(0xFF3A423A);
const Color kDarkOnSurfaceVariant = Color(0xFFC4C7C4);
const Color kDarkOutline = Color(0xFF8E918E);