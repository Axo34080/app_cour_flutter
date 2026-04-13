import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/components.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final ok = await context.read<AuthProvider>().signup(
          _emailCtrl.text.trim(),
          _usernameCtrl.text.trim(),
          _passCtrl.text,
        );

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      final error = context.read<AuthProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Erreur inconnue')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: SingleChildScrollView(
        child: CyberCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CyberTextField(
                  label: 'Email',
                  controller: _emailCtrl,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ),
                const SizedBox(height: 14),
                CyberTextField(
                  label: "Nom d'utilisateur",
                  controller: _usernameCtrl,
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: Validators.username,
                ),
                const SizedBox(height: 14),
                CyberTextField(
                  label: 'Mot de passe',
                  controller: _passCtrl,
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  validator: Validators.password,
                ),
                const SizedBox(height: 14),
                ListenableBuilder(
                  listenable: _passCtrl,
                  builder: (context, _) => CyberTextField(
                    label: 'Confirmer le mot de passe',
                    controller: _confirmCtrl,
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    validator: Validators.confirmPassword(_passCtrl.text),
                    accentColor: const Color(0xFFFF006E),
                  ),
                ),
                const SizedBox(height: 24),
                CyberButton(
                  label: 'Créer mon compte',
                  icon: Icons.person_add_outlined,
                  onPressed: _submit,
                  loading: _loading,
                ),
                const SizedBox(height: 12),
                const CyberDivider(label: 'ou'),
                Center(
                  child: CyberButton.ghost(
                    label: 'Déjà un compte ? Se connecter',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
