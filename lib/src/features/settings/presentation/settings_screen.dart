import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plant_disease_detector/src/core/theme/theme_provider.dart';
import 'package:plant_disease_detector/src/core/services/sync_service.dart';
import 'package:plant_disease_detector/src/core/storage/local_storage_service.dart';
import 'package:plant_disease_detector/src/features/auth/providers/auth_provider.dart';

/// Notifier for notification settings
class NotificationsNotifier extends Notifier<bool> {
  @override
  bool build() {
    return LocalStorageService.settingsBox.get('notifications_enabled', defaultValue: true) as bool;
  }
  
  void toggle(bool value) {
    state = value;
    LocalStorageService.settingsBox.put('notifications_enabled', value);
  }
}

final notificationsEnabledProvider = NotifierProvider<NotificationsNotifier, bool>(NotificationsNotifier.new);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final authState = ref.watch(authProvider);
    final syncState = ref.watch(syncNotifierProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        children: [
          // Profile Section
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  backgroundImage: user?.avatarUrl != null 
                    ? NetworkImage(user!.avatarUrl!)
                    : null,
                  child: user?.avatarUrl == null
                    ? Icon(
                        user?.isAdmin == true ? Icons.admin_panel_settings : Icons.person,
                        size: 32,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      )
                    : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user?.displayNameOrEmail ?? 'Misafir',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (user?.isAdmin == true) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Admin',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.isGuest == true 
                          ? 'Misafir Hesabı' 
                          : user?.email ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (user?.isGuest == true)
                  TextButton(
                    onPressed: () => context.push('/auth/signup'),
                    child: const Text('Kayıt Ol'),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => context.push('/settings/edit-profile'),
                  ),
              ],
            ),
          ),
          
          // Sync Status (only for authenticated users)
          if (authState.isAuthenticated) ...[
            _buildSectionHeader(context, 'Senkronizasyon'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    syncState.status == SyncStatus.syncing 
                      ? Icons.sync 
                      : syncState.status == SyncStatus.success
                        ? Icons.cloud_done
                        : Icons.cloud_outlined,
                    color: syncState.status == SyncStatus.error 
                      ? Colors.red 
                      : Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          syncState.status == SyncStatus.syncing
                            ? 'Senkronize ediliyor...'
                            : syncState.lastSyncAt != null
                              ? 'Son sync: ${_formatDate(syncState.lastSyncAt!)}'
                              : 'Henüz senkronize edilmedi',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (syncState.message != null && syncState.status != SyncStatus.idle)
                          Text(
                            syncState.message!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: syncState.status == SyncStatus.syncing
                      ? null
                      : () => ref.read(syncNotifierProvider.notifier).sync(user!.id),
                    child: Text(syncState.status == SyncStatus.syncing ? 'Bekleniyor' : 'Sync'),
                  ),
                ],
              ),
            ),
          ],
          
          // Settings List
          _buildSectionHeader(context, 'Hesap Yönetimi'),
          _buildSettingsItem(
            context, 
            Icons.person_outline, 
            'Hesap Bilgileri', 
            onTap: user?.isGuest == true ? null : () => context.push('/settings/edit-profile'),
          ),
          _buildNotificationSettings(context, ref),
          
          _buildSectionHeader(context, 'Uygulama Ayarları'),
          _buildSettingsItem(context, Icons.language, 'Dil', trailing: const Text('Türkçe')),
          _buildSettingsItem(
            context,
            Icons.dark_mode_outlined,
            'Koyu Tema',
            trailing: Switch(
              value: isDarkMode,
              onChanged: (val) {
                ref.read(themeControllerProvider.notifier).toggleTheme(val);
              },
            ),
          ),
          
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton(
              onPressed: () async {
                await ref.read(authProvider.notifier).signOut();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.red.withOpacity(0.1),
              ),
              child: Text(user?.isGuest == true ? 'Çıkış' : 'Çıkış Yap'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dakika önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    return '${diff.inDays} gün önce';
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    IconData icon,
    String title, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildNotificationSettings(BuildContext context, WidgetRef ref) {
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    
    return ExpansionTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.notifications_outlined, color: Theme.of(context).colorScheme.primary),
      ),
      title: const Text('Bildirimler'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: notificationsEnabled 
                ? Colors.green.withOpacity(0.2) 
                : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              notificationsEnabled ? 'Açık' : 'Kapalı',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: notificationsEnabled ? Colors.green : Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.expand_more),
        ],
      ),
      children: [
        SwitchListTile(
          title: const Text('Sulama Hatırlatıcıları'),
          subtitle: const Text('Bitkilerinizi sulamanız gerektiğinde bildirim alın'),
          value: notificationsEnabled,
          onChanged: (value) {
            ref.read(notificationsEnabledProvider.notifier).toggle(value);
          },
          secondary: Icon(
            Icons.water_drop,
            color: notificationsEnabled ? Colors.blue : Colors.grey,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.access_time, color: Colors.orange),
          title: const Text('Hatırlatma Saati'),
          subtitle: const Text('Her bitki için ayrı ayarlanabilir'),
          trailing: const Text('Bahçem\'den'),
          onTap: () {},
        ),
      ],
    );
  }
}
