import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_disease_detector/src/features/garden/providers/garden_provider.dart';
import 'package:plant_disease_detector/src/features/garden/data/plant_model.dart';

class AddPlantScreen extends ConsumerStatefulWidget {
  const AddPlantScreen({super.key});

  @override
  ConsumerState<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends ConsumerState<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _locationController = TextEditingController();
  
  WateringFrequency _wateringFrequency = WateringFrequency.weekly;
  int _customDays = 7;
  bool _notificationsEnabled = true;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
    );
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
    );
    
    if (time != null) {
      setState(() {
        _notificationTime = time;
      });
    }
  }

  Future<void> _savePlant() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      await ref.read(gardenProvider.notifier).addPlant(
        name: _nameController.text.trim(),
        species: _speciesController.text.trim().isEmpty ? null : _speciesController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        localImagePath: _selectedImage?.path,
        wateringFrequency: _wateringFrequency,
        customWateringDays: _wateringFrequency == WateringFrequency.custom ? _customDays : null,
        notificationsEnabled: _notificationsEnabled,
        notificationHour: _notificationTime.hour,
        notificationMinute: _notificationTime.minute,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_nameController.text} eklendi! 🌱'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitki Ekle'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePlant,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Kaydet'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image picker
            GestureDetector(
              onTap: () => _showImageOptions(),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Fotoğraf Ekle',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Name field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Bitki Adı *',
                hintText: 'örn. Mutfak Fesleğeni',
                prefixIcon: const Icon(Icons.eco),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Bitki adı gerekli';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Species field
            TextFormField(
              controller: _speciesController,
              decoration: InputDecoration(
                labelText: 'Tür (Opsiyonel)',
                hintText: 'örn. Ocimum basilicum',
                prefixIcon: const Icon(Icons.nature),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Location field
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Konum (Opsiyonel)',
                hintText: 'örn. Balkon, Mutfak penceresi',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Watering frequency section
            Text(
              'Sulama Sıklığı',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: WateringFrequency.values.map((freq) {
                final isSelected = _wateringFrequency == freq;
                return ChoiceChip(
                  label: Text(freq.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _wateringFrequency = freq);
                    }
                  },
                );
              }).toList(),
            ),
            
            // Custom days slider
            if (_wateringFrequency == WateringFrequency.custom) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Her $_customDays günde bir'),
                  const Spacer(),
                ],
              ),
              Slider(
                value: _customDays.toDouble(),
                min: 1,
                max: 60,
                divisions: 59,
                label: '$_customDays gün',
                onChanged: (value) {
                  setState(() => _customDays = value.toInt());
                },
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Notifications section
            Text(
              'Bildirimler',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            SwitchListTile(
              title: const Text('Sulama Hatırlatıcısı'),
              subtitle: Text(_notificationsEnabled 
                  ? 'Sulama zamanı geldiğinde bildirim alacaksınız'
                  : 'Bildirimler kapalı'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
              },
            ),
            
            if (_notificationsEnabled)
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Bildirim Saati'),
                subtitle: Text(_notificationTime.format(context)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _selectTime,
              ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Fotoğraf Çek'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeriden Seç'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            if (_selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Fotoğrafı Kaldır', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedImage = null);
                },
              ),
          ],
        ),
      ),
    );
  }
}
