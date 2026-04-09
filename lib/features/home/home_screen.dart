// lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import '../../shared/widgets/top_app_bar_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBarWidget(title: 'Home'),
      body: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          // Banner utama
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            elevation: 4,
            color: colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '🌳 Delcom Plants 🌳',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Grid emoji tanaman
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ['🌱', '🌿', '🍃', '🥬'].map((emoji) {
              return Card(
                margin: const EdgeInsets.all(8),
                elevation: 4,
                color: colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    emoji,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}