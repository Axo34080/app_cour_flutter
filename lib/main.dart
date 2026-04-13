import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home.dart';
import 'pages/login.dart';
import 'pages/nav_shell.dart';
import 'pages/search_users.dart';
import 'pages/signup.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'services/auth_service.dart';
import 'services/message_service.dart';
import 'services/socket_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: AuthService(),
            storageService: StorageService(),
          )..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(
            messageService: MessageService(),
            socketService: SocketService(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _Root(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignupPage(),
        '/home': (_) => const HomePage(),
        '/search': (_) => const SearchUsersPage(),
      },
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chat = context.read<ChatProvider>();
      if (auth.status == AuthStatus.authenticated && auth.token != null) {
        chat
          ..setMyId(auth.user?.id ?? '')
          ..connect(auth.token!);
      } else if (auth.status == AuthStatus.unauthenticated) {
        chat.disconnect();
      }
    });

    return switch (auth.status) {
      AuthStatus.unknown => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      AuthStatus.authenticated => const NavShell(),
      AuthStatus.unauthenticated => const HomePage(),
    };
  }
}
