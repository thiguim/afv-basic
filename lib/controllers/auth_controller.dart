import 'package:flutter/foundation.dart';

/// Responsável pela autenticação do usuário.
/// A View chama [login], aguarda o resultado e decide a navegação.
class AuthController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Tenta autenticar o usuário. Retorna [true] em caso de sucesso.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simula latência de rede (protótipo)
    await Future.delayed(const Duration(milliseconds: 1200));

    if (email.trim().isEmpty || password.trim().isEmpty) {
      _isLoading = false;
      _errorMessage = 'Preencha todos os campos.';
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
