import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthService authService,
    required StorageService storageService,
  })  : _auth = authService,
        _storage = storageService;

  final AuthService _auth;
  final StorageService _storage;

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  String? _token;
  String? _error;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get token => _token;
  String? get error => _error;
  bool get isLoading => _status == AuthStatus.unknown;

  /// Appelé au démarrage pour restaurer la session depuis le stockage.
  Future<void> init() async {
    final token = await _storage.readToken();
    final user = await _storage.readUser();

    if (token != null && user != null) {
      _token = token;
      _user = user;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _error = null;
    notifyListeners();
    try {
      final result = await _auth.login(email, password);
      await _storage.saveAuth(result.token, result.user);
      _token = result.token;
      _user = result.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Impossible de joindre le serveur';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String email, String username, String password) async {
    _error = null;
    notifyListeners();
    try {
      final result = await _auth.signup(email, username, password);
      await _storage.saveAuth(result.token, result.user);
      _token = result.token;
      _user = result.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Impossible de joindre le serveur';
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshUser(User updated) async {
    _user = updated;
    await _storage.saveAuth(_token!, updated);
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.clear();
    _token = null;
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
