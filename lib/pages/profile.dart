import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../components/components.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _userService = UserService();

  bool _loading = false;
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _usernameCtrl.text = user.username;
      _bioCtrl.text = user.bio ?? '';
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null || !mounted) return;

    final auth = context.read<AuthProvider>();
    setState(() => _uploadingAvatar = true);
    try {
      final token = auth.token!;
      final bytes = await picked.readAsBytes();
      final url = await _userService.uploadAvatar(token, bytes, picked.name);
      final updated = await _userService.updateMe(token, {'avatar': url});
      if (!mounted) return;
      await auth.refreshUser(updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    setState(() => _loading = true);
    try {
      final updated = await _userService.updateMe(auth.token!, {
        'username': _usernameCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
      });
      if (!mounted) return;
      await auth.refreshUser(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: SingleChildScrollView(
        child: CyberCard(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar
                GestureDetector(
                  onTap: _uploadingAvatar ? null : _pickAvatar,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CyberAvatar(
                        username: user?.username ?? '',
                        avatarPath: user?.avatar,
                        radius: 44,
                      ),
                      if (_uploadingAvatar)
                        const CyberLoader(size: 24)
                      else
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.neonCyan,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.background, width: 2),
                            ),
                            child: const Icon(Icons.edit, size: 14, color: AppColors.background),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    color: AppColors.textPrimary.withValues(alpha: 0.4),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                CyberTextField(
                  label: "Nom d'utilisateur",
                  controller: _usernameCtrl,
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: Validators.username,
                ),
                const SizedBox(height: 14),
                CyberTextField(
                  label: 'Bio',
                  controller: _bioCtrl,
                  prefixIcon: Icons.info_outline,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),
                CyberButton(
                  label: 'Enregistrer',
                  icon: Icons.save_outlined,
                  onPressed: _save,
                  loading: _loading,
                ),
                const SizedBox(height: 12),
                const CyberDivider(),
                CyberButton.secondary(
                  label: 'Se déconnecter',
                  icon: Icons.logout,
                  onPressed: () => context.read<AuthProvider>().logout(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
