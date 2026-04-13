import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/components.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final ok = await context.read<AuthProvider>().login(
          _emailCtrl.text.trim(),
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
      appBar: AppBar(title: const Text('Connexion')),
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
                  label: 'Mot de passe',
                  controller: _passCtrl,
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: Validators.password,
                ),
                const SizedBox(height: 24),
                CyberButton(
                  label: 'Se connecter',
                  icon: Icons.login,
                  onPressed: _submit,
                  loading: _loading,
                ),
                const SizedBox(height: 12),
                const CyberDivider(label: 'ou'),
                Center(
                  child: CyberButton.ghost(
                    label: 'Créer un compte',
                    icon: Icons.person_add_outlined,
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
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
