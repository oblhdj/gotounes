import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_colors.dart';
import 'config/app_config.dart';
import 'data/dummy_destinations.dart';
import 'models/destination.dart';
import 'screens/explore_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/splash_screen.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Never leak sensitive values (email/password/tokens) in production logs.
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // In dev, optionally skip Supabase and auth entirely.
  if (!devAuthBypass) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  runApp(const GoTounesApp());
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class GoTounesApp extends StatelessWidget {
  const GoTounesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.notoSansTextTheme(),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.25),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: AppColors.textPrimary,
            );
          }
          return TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: AppColors.textSecondary,
          );
        }),
      ),
    );

    return MaterialApp(
      title: 'GoTounes',
      debugShowCheckedModeBanner: false,
      theme: base,
      scrollBehavior: AppScrollBehavior(),
      home: const AuthGate(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showSplash = true;
  Session? _session;
  StreamSubscription<AuthState>? _subscription;

  void _dismissSplash() {
    if (!mounted || !_showSplash) return;
    setState(() {
      _showSplash = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _startAuthListener();
  }

  void _startAuthListener() {
    if (devAuthBypass) {
      _session = null;
      _dismissSplash();
      return;
    }

    Future<void>.delayed(const Duration(seconds: 1), _dismissSplash);

    try {
      final auth = Supabase.instance.client.auth;
      _session = auth.currentSession;
      if (_session != null) {
        _dismissSplash();
      }

      _subscription = auth.onAuthStateChange.listen((AuthState data) {
        if (!mounted) return;
        _dismissSplash();

        if (data.event == AuthChangeEvent.passwordRecovery) {
          Navigator.of(context).pushNamed('/reset-password');
        }
        setState(() {
          _session = data.session;
        });
      });
    } catch (_) {
      // Widget tests may pump `GoTounesApp` directly without calling `main()`.
      // In that case, avoid crashing and keep the login screen visible.
      _session = null;
      _dismissSplash();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) return const SplashScreen();
    if (devAuthBypass) return const MainShell();
    if (_session == null) return const LoginScreen();
    return const MainShell();
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late final SupabaseService _supabaseService = SupabaseService();
  int _index = 0;
  List<Destination> _destinations = const [];
  Map<String, String> _profile = const {};
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadAppData();
  }

  Future<void> _loadAppData() async {
    if (devAuthBypass) {
      setState(() {
        _destinations = List<Destination>.from(dummyDestinations);
        _profile = const {
          'display_name': 'Dev Guest',
          'email': 'guest@local.dev',
        };
        _isLoading = false;
        _loadError = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      await _supabaseService.syncCurrentUserProfile();
      final results = await Future.wait<dynamic>([
        _supabaseService.getDestinations(),
        _supabaseService.getUserProfile(),
      ]);

      if (!mounted) return;
      setState(() {
        _destinations = results[0] as List<Destination>;
        _profile = results[1] as Map<String, String>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(String id) async {
    final previous = _destinations;
    setState(() {
      _destinations = _destinations.map((d) {
        if (d.id == id) return d.copyWith(isFavorite: !d.isFavorite);
        return d;
      }).toList();
    });

    if (devAuthBypass) return;

    try {
      await _supabaseService.toggleFavorite(id);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _destinations = previous;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _logout() async {
    if (devAuthBypass) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign out is disabled in dev bypass mode.'),
        ),
      );
      return;
    }

    try {
      await _supabaseService.signOut();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['GoTounes', 'Explore', 'Favorites', 'Profile'];

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 56),
                const SizedBox(height: 16),
                const Text(
                  'Unable to load your travel data.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _loadError!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loadAppData,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          if (_index == 0)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
            ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(
            destinations: _destinations,
            onFavoriteToggle: (id) {
              _toggleFavorite(id);
            },
            onSearchTap: () {
              setState(() => _index = 1);
            },
          ),
          ExploreScreen(
            destinations: _destinations,
            onFavoriteToggle: (id) {
              _toggleFavorite(id);
            },
          ),
          FavoritesScreen(
            destinations: _destinations,
            onFavoriteToggle: (id) {
              _toggleFavorite(id);
            },
          ),
          ProfileScreen(
            favoritesCount:
                _destinations.where((d) => d.isFavorite).length,
            visitedCount: 0,
            submittedCount: 0,
            displayName: _profile['display_name'] ?? 'Traveler',
            email: _profile['email'] ?? '',
            bio: _profile['bio'] ?? '',
            location: _profile['location'] ?? '',
            avatarUrl: _profile['avatar_url'] ?? '',
            onProfileUpdated: _loadAppData,
            onLogout: () {
              _logout();
            },
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
