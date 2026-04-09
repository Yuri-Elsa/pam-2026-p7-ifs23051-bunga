// lib/features/flowers/flowers_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/route_constants.dart';
import '../../data/models/flower_model.dart';
import '../../providers/flower_provider.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/top_app_bar_widget.dart';

class FlowersDetailScreen extends StatefulWidget {
  const FlowersDetailScreen({super.key, required this.flowerId});

  final String flowerId;

  @override
  State<FlowersDetailScreen> createState() => _FlowersDetailScreenState();
}

class _FlowersDetailScreenState extends State<FlowersDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FlowerProvider>().loadFlowerById(widget.flowerId);
    });
  }

  Future<void> _confirmDelete(
      BuildContext context, FlowerProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Bunga'),
        content: const Text('Apakah kamu yakin ingin menghapus data bunga ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await provider.removeFlower(widget.flowerId);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bunga berhasil dihapus.')),
        );
        context.go(RouteConstants.flowers);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FlowerProvider>(
      builder: (context, provider, _) {
        if (provider.status == FlowerStatus.loading ||
            provider.status == FlowerStatus.initial) {
          return Scaffold(
            appBar: const TopAppBarWidget(
              title: 'Detail Bunga',
              showBackButton: true,
            ),
            body: const LoadingWidget(),
          );
        }

        if (provider.status == FlowerStatus.error) {
          return Scaffold(
            appBar: const TopAppBarWidget(
              title: 'Detail Bunga',
              showBackButton: true,
            ),
            body: AppErrorWidget(
              message: provider.errorMessage,
              onRetry: () => provider.loadFlowerById(widget.flowerId),
            ),
          );
        }

        final flower = provider.selectedFlower;
        if (flower == null) {
          return Scaffold(
            appBar: const TopAppBarWidget(
              title: 'Detail Bunga',
              showBackButton: true,
            ),
            body: const Center(child: Text('Data tidak ditemukan.')),
          );
        }

        return Scaffold(
          appBar: TopAppBarWidget(
            title: flower.namaUmum,
            showBackButton: true,
            menuItems: [
              TopAppBarMenuItem(
                text: 'Edit',
                icon: Icons.edit_outlined,
                onTap: () async {
                  final edited = await context.push<bool>(
                    RouteConstants.flowersEdit(flower.id!),
                  );
                  if (edited == true && context.mounted) {
                    provider.loadFlowerById(widget.flowerId);
                  }
                },
              ),
              TopAppBarMenuItem(
                text: 'Hapus',
                icon: Icons.delete_outline,
                isDestructive: true,
                onTap: () => _confirmDelete(context, provider),
              ),
            ],
          ),
          body: _FlowersDetailBody(flower: flower),
        );
      },
    );
  }
}

// ── Detail Body ───────────────────────────────────────────────────────────────

class _FlowersDetailBody extends StatelessWidget {
  const _FlowersDetailBody({required this.flower});

  final FlowerModel flower;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Hero image + nama
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    flower.gambar,
                    width: double.infinity,
                    height: 260,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 260,
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.local_florist,
                        size: 80,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Nama umum
                Text(
                  flower.namaUmum,
                  style: textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // Nama latin (italic)
                Text(
                  flower.namaLatin,
                  style: textTheme.titleMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Badge makna besar
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: colorScheme.secondary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite,
                          size: 16, color: colorScheme.secondary),
                      const SizedBox(width: 6),
                      Text(
                        flower.makna,
                        style: textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          _InfoCard(title: 'Deskripsi', content: flower.deskripsi,
              icon: Icons.description_outlined),
          const SizedBox(height: 12),
          _InfoCard(
              title: 'Asal Budaya',
              content: flower.asalBudaya,
              icon: Icons.public_outlined),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.content,
    required this.icon,
  });

  final String title;
  final String content;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}