import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:plant_disease_detector/src/features/garden/providers/garden_provider.dart';
import 'package:plant_disease_detector/src/features/garden/data/plant_model.dart';

class PlantDetailScreen extends ConsumerStatefulWidget {
  final String plantId;

  const PlantDetailScreen({super.key, required this.plantId});

  @override
  ConsumerState<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends ConsumerState<PlantDetailScreen> {
  final _noteController = TextEditingController();
  NoteType _selectedNoteType = NoteType.general;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plant = ref.watch(plantProvider(widget.plantId));
    final theme = Theme.of(context);
    
    if (plant == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Bitki bulunamadı')),
      );
    }
    
    final notes = ref.watch(gardenProvider.notifier).getNotesForPlant(widget.plantId);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                plant.name,
                style: const TextStyle(
                  shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                ),
              ),
              background: plant.localImagePath != null
                  ? Image.file(
                      File(plant.localImagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(theme),
                    )
                  : plant.imageUrl != null
                      ? Image.network(
                          plant.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(theme),
                        )
                      : _buildPlaceholder(theme),
            ),
            actions: [
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Düzenle'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Sil', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'delete') {
                    _confirmDelete(context, plant);
                  }
                },
              ),
            ],
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info cards
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.water_drop,
                          title: 'Sulama',
                          value: plant.wateringFrequency.displayName,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.location_on,
                          title: 'Konum',
                          value: plant.location ?? 'Belirtilmedi',
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Watering status card
                  _buildWateringCard(context, plant),
                  
                  const SizedBox(height: 24),
                  
                  // Quick actions
                  Text(
                    'Hızlı İşlemler',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.water_drop,
                          label: 'Suladım',
                          color: Colors.blue,
                          onTap: () => _waterPlant(plant),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.note_add,
                          label: 'Not Ekle',
                          color: Colors.green,
                          onTap: () => _showAddNoteDialog(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.settings,
                          label: 'Ayarlar',
                          color: Colors.purple,
                          onTap: () => _showSettingsDialog(context, plant),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Notes section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Notlar',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${notes.length} not',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (notes.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.note_outlined,
                              size: 48,
                              color: theme.colorScheme.onSurface.withOpacity(0.3),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Henüz not eklenmemiş',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...notes.map((note) => _NoteCard(
                      note: note,
                      onDelete: () => _deleteNote(note.id),
                    )),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primaryContainer,
      child: Center(
        child: Icon(
          Icons.eco,
          size: 80,
          color: theme.colorScheme.primary.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildWateringCard(BuildContext context, PlantModel plant) {
    final theme = Theme.of(context);
    final needsWater = plant.needsWatering;
    final days = plant.daysUntilWatering;
    
    String statusText;
    Color statusColor;
    IconData statusIcon;
    
    if (plant.lastWateredAt == null) {
      statusText = 'Henüz sulanmadı';
      statusColor = Colors.orange;
      statusIcon = Icons.warning_amber;
    } else if (days < 0) {
      statusText = '${-days} gün gecikti!';
      statusColor = Colors.red;
      statusIcon = Icons.error;
    } else if (days == 0) {
      statusText = 'Bugün sulanmalı';
      statusColor = Colors.blue;
      statusIcon = Icons.water_drop;
    } else {
      statusText = '$days gün sonra sulanacak';
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                if (plant.lastWateredAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Son sulama: ${DateFormat('d MMMM yyyy', 'tr').format(plant.lastWateredAt!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _waterPlant(PlantModel plant) async {
    await ref.read(gardenProvider.notifier).waterPlant(plant.id);
    
    // Also add a watering note
    await ref.read(gardenProvider.notifier).addNote(
      plantId: plant.id,
      content: 'Bitki sulandı 💧',
      type: NoteType.watering,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sulama kaydedildi! 💧'),
          backgroundColor: Colors.blue,
        ),
      );
      setState(() {}); // Refresh notes
    }
  }

  void _showAddNoteDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Not Ekle',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Note type chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: NoteType.values.map((type) {
                  final isSelected = _selectedNoteType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('${type.icon} ${type.displayName}'),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedNoteType = type);
                          Navigator.pop(context);
                          _showAddNoteDialog(context);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Notunuzu yazın...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            
            const SizedBox(height: 16),
            
            FilledButton(
              onPressed: () async {
                if (_noteController.text.trim().isEmpty) return;
                
                await ref.read(gardenProvider.notifier).addNote(
                  plantId: widget.plantId,
                  content: _noteController.text.trim(),
                  type: _selectedNoteType,
                );
                
                _noteController.clear();
                _selectedNoteType = NoteType.general;
                
                if (mounted) {
                  Navigator.pop(context);
                  setState(() {}); // Refresh
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Not eklendi! 📝'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Kaydet'),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _deleteNote(String noteId) async {
    await ref.read(gardenProvider.notifier).deleteNote(noteId);
    setState(() {});
  }

  void _confirmDelete(BuildContext context, PlantModel plant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bitkiyi Sil'),
        content: Text('${plant.name} silinecek. Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(gardenProvider.notifier).deletePlant(plant.id);
              if (mounted) {
                Navigator.pop(context);
                context.pop();
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, PlantModel plant) {
    WateringFrequency selectedFrequency = plant.wateringFrequency;
    int customDays = plant.customWateringDays ?? 7;
    bool notificationsEnabled = plant.notificationsEnabled;
    TimeOfDay notificationTime = TimeOfDay(
      hour: plant.notificationHour,
      minute: plant.notificationMinute,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sulama Ayarları',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Watering frequency
              Text(
                'Sulama Sıklığı',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: WateringFrequency.values.map((freq) {
                  final isSelected = selectedFrequency == freq;
                  return ChoiceChip(
                    label: Text(freq.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      setModalState(() {
                        selectedFrequency = freq;
                      });
                    },
                  );
                }).toList(),
              ),
              
              // Custom days input
              if (selectedFrequency == WateringFrequency.custom) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Her '),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                        controller: TextEditingController(text: customDays.toString()),
                        onChanged: (value) {
                          final days = int.tryParse(value);
                          if (days != null && days > 0) {
                            customDays = days;
                          }
                        },
                      ),
                    ),
                    const Text(' günde bir'),
                  ],
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Notification settings
              SwitchListTile(
                title: const Text('Sulama Bildirimleri'),
                subtitle: const Text('Sulama zamanı geldiğinde bildirim al'),
                value: notificationsEnabled,
                onChanged: (value) {
                  setModalState(() {
                    notificationsEnabled = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              
              if (notificationsEnabled) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time),
                  title: const Text('Bildirim Saati'),
                  subtitle: Text(
                    '${notificationTime.hour.toString().padLeft(2, '0')}:${notificationTime.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: notificationTime,
                    );
                    if (time != null) {
                      setModalState(() {
                        notificationTime = time;
                      });
                    }
                  },
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Save button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    // Update plant settings
                    final updatedPlant = plant.copyWith(
                      wateringFrequency: selectedFrequency,
                      customWateringDays: customDays,
                      notificationsEnabled: notificationsEnabled,
                      notificationHour: notificationTime.hour,
                      notificationMinute: notificationTime.minute,
                    );
                    
                    await ref.read(gardenProvider.notifier).updatePlant(updatedPlant);
                    
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ayarlar kaydedildi! ✅'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Kaydet'),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final PlantNote note;
  final VoidCallback onDelete;

  const _NoteCard({required this.note, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                note.type.icon,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Text(
                note.type.displayName,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('d MMM', 'tr').format(note.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: onDelete,
                color: Colors.red.withOpacity(0.7),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(note.content),
        ],
      ),
    );
  }
}
