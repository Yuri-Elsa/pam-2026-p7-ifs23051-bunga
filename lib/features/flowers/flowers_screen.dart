// lib/features/flowers/flowers_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/route_constants.dart';
import '../../data/models/flower_model.dart';
import '../../providers/flower_provider.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/top_app_bar_widget.dart';

class FlowersScreen extends StatefulWidget {
  const FlowersScreen({super.key});

  @override
  State<FlowersScreen> createState() => _FlowersScreenState();
}

class _FlowersScreenState extends State<FlowersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FlowerProvider>().loadFlowers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FlowerProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: TopAppBarWidget(
            title: 'Bahasa Bunga',
            withSearch: true,
            searchQuery: provider.searchQuery,
            onSearchQueryChange: provider.updateSearchQuery,
          ),
          body: _buildBody(provider),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final added =
              await context.push<bool>(RouteConstants.flowersAdd);
              if (added == true && context.mounted) {
                provider.loadFlowers();
              }
            },
            tooltip: 'Tambah Bunga',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildBody(FlowerProvider provider) {
    return switch (provider.status) {
      FlowerStatus.loading || FlowerStatus.initial => const LoadingWidget(),
      FlowerStatus.error => AppErrorWidget(
        message: provider.errorMessage,
        onRetry: () => provider.loadFlowers(),
      ),
      FlowerStatus.success => _FlowersBody(
        flowers: provider.flowers,
        onOpen: (id) => context.go(RouteConstants.flowersDetail(id)),
      ),
    };
  }
}

// ── List Body ─────────────────────────────────────────────────────────────────

class _FlowersBody extends StatelessWidget {
  const _FlowersBody({required this.flowers, required this.onOpen});

  final List<FlowerModel> flowers;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    if (flowers.isEmpty) {
      return Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Tidak ada data bahasa bunga!',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<FlowerProvider>().loadFlowers(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: flowers.length,
        itemBuilder: (context, index) {
          return _FlowerItemCard(
            flower: flowers[index],
            onOpen: onOpen,
          );
        },
      ),
    );
  }
}

// ── Item Card ─────────────────────────────────────────────────────────────────

class _FlowerItemCard extends StatelessWidget {
  const _FlowerItemCard({required this.flower, required this.onOpen});

  final FlowerModel flower;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onOpen(flower.id!),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Gambar bunga
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  flower.gambar,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.local_florist,
                        color: colorScheme.secondary),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      width: 70,
                      height: 70,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Info bunga
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flower.namaUmum,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      flower.namaLatin,
                      style: textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Badge makna
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        flower.makna,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}