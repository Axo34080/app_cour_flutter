import 'package:flutter/material.dart';
import '../components/components.dart';
import '../theme/app_theme.dart';

/// Page d'accueil / splash.
/// Plus tard : vérifie le token stocké et redirige automatiquement.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: CyberCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CyberAvatar(username: 'OnlyVent', radius: 40),
                const SizedBox(height: 20),
                Text(
                  'OnlyVent',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.neonCyan,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Chat privé & sécurisé',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary.withValues(alpha: 0.5),
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 32),
                CyberButton(
                  label: 'Commencer',
                  icon: Icons.arrow_forward,
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
