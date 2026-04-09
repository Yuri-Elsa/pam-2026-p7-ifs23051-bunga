// lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/route_constants.dart';
import '../../shared/widgets/top_app_bar_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBarWidget(title: 'Beranda'),
      body: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Banner Hero ──
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🌿', style: textTheme.displaySmall),
                    const SizedBox(width: 8),
                    Text('🌸', style: textTheme.displaySmall),
                    const SizedBox(width: 8),
                    Text('🌼', style: textTheme.displaySmall),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Delcom Plants',
                  style: textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Ensiklopedia Tanaman & Bahasa Bunga',
                  style: textTheme.bodyMedium?.copyWith(
                    color:
                    colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // ── Section Label ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Jelajahi Fitur',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // ── Menu Cards ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _FeatureCard(
                    emoji: '🌱',
                    title: 'Tanaman',
                    subtitle: 'Jelajahi koleksi tanaman beserta manfaatnya',
                    color: colorScheme.primaryContainer,
                    textColor: colorScheme.onPrimaryContainer,
                    onTap: () => context.go(RouteConstants.plants),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FeatureCard(
                    emoji: '🌸',
                    title: 'Bunga',
                    subtitle: 'Temukan makna tersembunyi di balik setiap bunga',
                    color: colorScheme.secondaryContainer,
                    textColor: colorScheme.onSecondaryContainer,
                    onTap: () => context.go(RouteConstants.flowers),
                  ),
                ),
              ],
            ),
          ),

          // ── Fact Section ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'Tahukah Kamu?',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ..._facts.map(
                (fact) => _FactTile(
              icon: fact.$1,
              text: fact.$2,
            ),
          ),
        ],
      ),
    );
  }

  // (icon, text) facts
  static const List<(String, String)> _facts = [
    (
    '🌹',
    'Bahasa bunga (floriografi) pertama kali populer di era Victoria abad ke-19.',
    ),
    (
    '🌿',
    'Indonesia memiliki lebih dari 30.000 spesies tanaman berbunga.',
    ),
    (
    '🌼',
    'Bunga matahari selalu menghadap matahari — fenomena ini disebut heliotrop.',
    ),
    (
    '🌱',
    'Tanaman herbal telah digunakan sebagai obat tradisional selama ribuan tahun.',
    ),
  ];
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: textColor.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Lihat semua',
                    style: textTheme.labelSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_forward, size: 12, color: textColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FactTile extends StatelessWidget {
  const _FactTile({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: textTheme.titleLarge),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}