import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search plant or disease...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.primary.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildFilterChip(context, 'Filter', icon: Icons.tune),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'Tomato', isSelected: true),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'Pepper', isSelected: true),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'Last Month', isSelected: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // History List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildHistoryItem(
                  context,
                  plantName: 'Vine Tomato',
                  diseaseName: 'Leaf Mold',
                  date: '15.08.2023',
                  imageUrl: 'https://i.imgur.com/5J898dD.jpeg', // Placeholder
                ),
                _buildHistoryItem(
                  context,
                  plantName: 'Pepper',
                  diseaseName: 'Powdery Mildew',
                  date: '12.07.2023',
                  imageUrl: 'https://i.imgur.com/5J898dD.jpeg', // Placeholder
                ),
                _buildHistoryItem(
                  context,
                  plantName: 'Cherry Tomato',
                  diseaseName: 'Early Blight',
                  date: '28.06.2023',
                  imageUrl: 'https://i.imgur.com/5J898dD.jpeg', // Placeholder
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, {IconData? icon, bool isSelected = false}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: theme.colorScheme.onSurface),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 4),
            Icon(Icons.close, size: 16, color: theme.colorScheme.onSurface),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context, {
    required String plantName,
    required String diseaseName,
    required String date,
    required String imageUrl,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
              color: Colors.grey[200],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plantName,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  diseaseName,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
