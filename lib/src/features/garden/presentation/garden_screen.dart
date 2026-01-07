import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plant_disease_detector/src/core/widgets/cached_image.dart';
import 'package:plant_disease_detector/src/features/garden/providers/garden_provider.dart';
import 'package:plant_disease_detector/src/features/garden/data/plant_model.dart';

class GardenScreen extends ConsumerWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gardenState = ref.watch(gardenProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bahçem'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/garden/add'),
          ),
        ],
      ),
      body: gardenState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : gardenState.plants.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: () async {
                    ref.read(gardenProvider.notifier).refresh();
                  },
                  child: CustomScrollView(
                    slivers: [
                      // Watering alert section
                      if (gardenState.plantsNeedingWater.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: _buildWateringAlert(context, gardenState.plantsNeedingWater),
                        ),
                      ],
                      
                      // Plants grid
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final plant = gardenState.plants[index];
                              return _PlantCard(plant: plant);
                            },
                            childCount: gardenState.plants.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.yard_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz bitki eklemediniz',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Bahçenizdeki bitkileri ekleyin ve takip edin',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push('/garden/add'),
              icon: const Icon(Icons.add),
              label: const Text('İlk Bitkini Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWateringAlert(BuildContext context, List<PlantModel> plants) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.water_drop, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${plants.length} bitki sulanmayı bekliyor',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plants.take(3).map((p) => p.name).join(', ') +
                      (plants.length > 3 ? '...' : ''),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlantCard extends ConsumerWidget {
  final PlantModel plant;

  const _PlantCard({required this.plant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final needsWater = plant.needsWatering;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/garden/plant/${plant.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image or placeholder
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (plant.localImagePath != null || plant.imageUrl != null)
                    CachedImage(
                      imagePath: plant.localImagePath ?? plant.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(theme),
                    )
                  else
                    _buildPlaceholder(theme),
                  
                  // Water indicator
                  if (needsWater)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.water_drop,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Info section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (plant.species != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        plant.species!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.water_drop_outlined,
                          size: 14,
                          color: needsWater ? Colors.blue : theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _getWateringText(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: needsWater ? Colors.blue : theme.colorScheme.onSurface.withOpacity(0.5),
                              fontWeight: needsWater ? FontWeight.bold : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
      child: Icon(
        Icons.eco,
        size: 48,
        color: theme.colorScheme.primary.withOpacity(0.5),
      ),
    );
  }

  String _getWateringText() {
    if (plant.lastWateredAt == null) {
      return 'Henüz sulanmadı';
    }
    
    final days = plant.daysUntilWatering;
    if (days < 0) {
      return '${-days} gün gecikti';
    } else if (days == 0) {
      return 'Bugün sulanmalı';
    } else if (days == 1) {
      return 'Yarın sulanmalı';
    } else {
      return '$days gün sonra';
    }
  }
}
