import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plant_disease_detector/src/features/auth/presentation/welcome_screen.dart';
import 'package:plant_disease_detector/src/features/auth/presentation/login_screen.dart';
import 'package:plant_disease_detector/src/features/auth/presentation/signup_screen.dart';
import 'package:plant_disease_detector/src/features/auth/presentation/forgot_password_screen.dart';
import 'package:plant_disease_detector/src/features/auth/providers/auth_provider.dart';
import 'package:plant_disease_detector/src/features/diagnose/presentation/plant_identification_screen.dart';
import 'package:plant_disease_detector/src/features/diagnose/presentation/diagnosis_result_screen.dart';
import 'package:plant_disease_detector/src/features/diagnose/presentation/treatment_screen.dart';
import 'package:plant_disease_detector/src/features/diagnose/data/plant_disease_info.dart';
import 'package:plant_disease_detector/src/features/home/presentation/home_screen.dart';
import 'package:plant_disease_detector/src/features/settings/presentation/settings_screen.dart';
import 'package:plant_disease_detector/src/features/settings/presentation/edit_profile_screen.dart';
import 'package:plant_disease_detector/src/features/garden/presentation/garden_screen.dart';
import 'package:plant_disease_detector/src/features/garden/presentation/add_plant_screen.dart';
import 'package:plant_disease_detector/src/features/garden/presentation/plant_detail_screen.dart';
import 'package:plant_disease_detector/src/features/chat/presentation/plant_chat_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: '/welcome',
    refreshListenable: _AuthStateNotifier(ref),
    redirect: (context, state) {
      final isInitial = authState.status == AuthStatus.initial;
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isGuest = authState.status == AuthStatus.guest;
      final isLoggedIn = isAuthenticated || isGuest;
      
      final location = state.matchedLocation;
      final isOnAuthPage = location == '/welcome' || 
                          location.startsWith('/auth/');
      
      // Still checking session - don't redirect yet
      if (isInitial) {
        return null;
      }
      
      // If not logged in and trying to access protected pages
      if (!isLoggedIn && !isOnAuthPage) {
        return '/welcome';
      }
      
      // If logged in and trying to access auth pages (except signup for guest conversion)
      if (isLoggedIn && isOnAuthPage) {
        // Allow guest to access signup for account conversion
        if (isGuest && location == '/auth/signup') {
          return null;
        }
        // Redirect to home for other auth pages
        if (location != '/auth/signup') {
          return '/home';
        }
      }
      
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // Profile routes
      GoRoute(
        path: '/settings/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      
      // Garden routes
      GoRoute(
        path: '/garden/add',
        builder: (context, state) => const AddPlantScreen(),
      ),
      GoRoute(
        path: '/garden/plant/:id',
        builder: (context, state) {
          final plantId = state.pathParameters['id']!;
          return PlantDetailScreen(plantId: plantId);
        },
      ),
      
      // App routes
      GoRoute(
        path: '/diagnose',
        builder: (context, state) => const PlantIdentificationScreen(),
      ),
      GoRoute(
        path: '/diagnosis-result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return DiagnosisResultScreen(
            imagePath: extra['imagePath'],
            label: extra['label'],
            confidence: extra['confidence'],
          );
        },
      ),
      GoRoute(
        path: '/treatment',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return TreatmentScreen(
            imagePath: extra['imagePath'],
            diseaseInfo: extra['diseaseInfo'] as PlantDiseaseInfo,
          );
        },
      ),
      
      // Chat route
      GoRoute(
        path: '/chat',
        builder: (context, state) => const PlantChatScreen(),
      ),
      
      // Shell route with bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithBottomNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/garden',
            builder: (context, state) => const GardenScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

/// Helper class to refresh router when auth state changes
class _AuthStateNotifier extends ChangeNotifier {
  _AuthStateNotifier(this.ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
  
  final Ref ref;
}

class ScaffoldWithBottomNavBar extends StatefulWidget {
  const ScaffoldWithBottomNavBar({super.key, required this.child});

  final Widget child;

  @override
  State<ScaffoldWithBottomNavBar> createState() => _ScaffoldWithBottomNavBarState();
}

class _ScaffoldWithBottomNavBarState extends State<ScaffoldWithBottomNavBar> {
  late PageController _pageController;
  int _currentIndex = 0;
  
  final List<Widget> _pages = const [
    HomeScreen(),
    GardenScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync page with current route
    final newIndex = _calculateSelectedIndex(context);
    if (newIndex != _currentIndex) {
      _currentIndex = newIndex;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentIndex);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
          _navigateToPage(index, context);
        },
        children: _pages,
      ),
      floatingActionButton: _currentIndex == 0
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Chat button (top right when there's a camera button)
                FloatingActionButton(
                  heroTag: 'chat_fab',
                  onPressed: () {
                    context.push('/chat');
                  },
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  mini: true,
                  child: const Icon(Icons.smart_toy, color: Colors.white),
                ),
                const SizedBox(height: 12),
                // Camera button
                FloatingActionButton(
                  heroTag: 'camera_fab',
                  onPressed: () {
                    context.push('/diagnose');
                  },
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.camera_alt, color: Colors.white),
                ),
              ],
            )
          : FloatingActionButton(
              heroTag: 'chat_fab_only',
              onPressed: () {
                context.push('/chat');
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              mini: true,
              child: const Icon(Icons.smart_toy, color: Colors.white),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (int idx) => _onItemTapped(idx),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Teşhislerim',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.yard_outlined),
            activeIcon: Icon(Icons.yard),
            label: 'Bahçem',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/garden')) {
      return 1;
    }
    if (location.startsWith('/settings')) {
      return 2;
    }
    return 0;
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _navigateToPage(index, context);
  }
  
  void _navigateToPage(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/home');
        break;
      case 1:
        GoRouter.of(context).go('/garden');
        break;
      case 2:
        GoRouter.of(context).go('/settings');
        break;
    }
  }
}
