import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:plant_disease_detector/src/features/auth/providers/auth_provider.dart';
import 'package:plant_disease_detector/src/core/services/image_compress_service.dart';
import 'package:plant_disease_detector/src/core/supabase/supabase_config.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  
  bool _isLoading = false;
  bool _isUploadingAvatar = false;
  String? _errorMessage;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _displayNameController.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<String?> _uploadAvatar() async {
    if (_selectedImage == null) return null;
    
    setState(() => _isUploadingAvatar = true);
    
    try {
      final user = ref.read(authProvider).user;
      if (user == null) throw Exception('Kullanıcı bulunamadı');
      
      // Compress image before upload
      final compressedFile = await ImageCompressService.compressForUpload(
        file: _selectedImage!,
        isAvatar: true,
      );
      
      if (compressedFile == null) throw Exception('Resim sıkıştırılamadı');
      
      final fileName = 'avatar_${user.id}.jpg';
      final storagePath = 'avatars/$fileName';
      
      await Supabase.instance.client.storage
          .from(SupabaseConfig.storageBucket)
          .upload(
            storagePath,
            compressedFile,
            fileOptions: const FileOptions(upsert: true),
          );
      
      final publicUrl = Supabase.instance.client.storage
          .from(SupabaseConfig.storageBucket)
          .getPublicUrl(storagePath);
      
      print('✅ Avatar uploaded: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Avatar upload error: $e');
      setState(() {
        _errorMessage = 'Avatar yüklenemedi: $e';
      });
      return null;
    } finally {
      setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      String? avatarUrl;
      
      // Upload avatar if selected
      if (_selectedImage != null) {
        avatarUrl = await _uploadAvatar();
      }
      
      // Update profile
      await ref.read(authProvider.notifier).updateProfile(
        displayName: _displayNameController.text.trim(),
        avatarUrl: avatarUrl,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil güncellendi'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
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
            // Avatar Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (user?.avatarUrl != null
                            ? NetworkImage(user!.avatarUrl!)
                            : null),
                    child: (_selectedImage == null && user?.avatarUrl == null)
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: theme.colorScheme.onPrimaryContainer,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: _isUploadingAvatar
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _isUploadingAvatar ? null : _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            Center(
              child: Text(
                'Profil fotoğrafını değiştirmek için dokunun',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Error Message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Display Name Field
            TextFormField(
              controller: _displayNameController,
              decoration: InputDecoration(
                labelText: 'Görünen Ad',
                hintText: 'Adınızı girin',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Görünen ad gerekli';
                }
                if (value.trim().length < 2) {
                  return 'Görünen ad en az 2 karakter olmalı';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Email Field (read-only)
            TextFormField(
              initialValue: user?.email ?? '',
              decoration: InputDecoration(
                labelText: 'E-posta',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              ),
              readOnly: true,
              enabled: false,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'E-posta adresi değiştirilemez',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Account Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hesap Bilgileri',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(context, 'Hesap Türü', user?.role.name ?? 'user'),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    'Kayıt Tarihi',
                    user?.createdAt != null
                        ? '${user!.createdAt.day}.${user.createdAt.month}.${user.createdAt.year}'
                        : '-',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
