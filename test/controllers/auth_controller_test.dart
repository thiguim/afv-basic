import 'package:flutter_test/flutter_test.dart';
import 'package:afv_basico/controllers/auth_controller.dart';

void main() {
  group('AuthController', () {
    late AuthController ctrl;

    setUp(() => ctrl = AuthController());
    tearDown(() => ctrl.dispose());

    group('estado inicial', () {
      test('isLoading começa como false', () {
        expect(ctrl.isLoading, isFalse);
      });

      test('errorMessage começa como null', () {
        expect(ctrl.errorMessage, isNull);
      });
    });

    group('login - credenciais válidas', () {
      test('retorna true com email e senha preenchidos', () async {
        final resultado = await ctrl.login('vendedor@empresa.com', '123456');
        expect(resultado, isTrue);
      });

      test('isLoading é false após login bem-sucedido', () async {
        await ctrl.login('vendedor@empresa.com', '123456');
        expect(ctrl.isLoading, isFalse);
      });

      test('errorMessage permanece null após sucesso', () async {
        await ctrl.login('vendedor@empresa.com', '123456');
        expect(ctrl.errorMessage, isNull);
      });
    });

    group('login - credenciais inválidas', () {
      test('retorna false com email vazio', () async {
        final resultado = await ctrl.login('', '123456');
        expect(resultado, isFalse);
      });

      test('retorna false com senha vazia', () async {
        final resultado = await ctrl.login('vendedor@empresa.com', '');
        expect(resultado, isFalse);
      });

      test('retorna false com ambos os campos vazios', () async {
        final resultado = await ctrl.login('', '');
        expect(resultado, isFalse);
      });

      test('retorna false com email apenas com espaços', () async {
        final resultado = await ctrl.login('   ', '123456');
        expect(resultado, isFalse);
      });

      test('define errorMessage ao falhar', () async {
        await ctrl.login('', '123456');
        expect(ctrl.errorMessage, isNotNull);
        expect(ctrl.errorMessage, isNotEmpty);
      });

      test('isLoading é false após falha', () async {
        await ctrl.login('', '');
        expect(ctrl.isLoading, isFalse);
      });
    });

    group('login - notificações', () {
      test('notifica listeners ao iniciar (isLoading = true)', () async {
        final estados = <bool>[];
        ctrl.addListener(() => estados.add(ctrl.isLoading));

        await ctrl.login('vendedor@empresa.com', '123456');

        // Primeira notificação: isLoading = true
        // Segunda notificação: isLoading = false
        expect(estados.length, greaterThanOrEqualTo(2));
        expect(estados.first, isTrue);
        expect(estados.last, isFalse);
      });
    });

    group('clearError', () {
      test('limpa errorMessage após falha de login', () async {
        await ctrl.login('', '');
        expect(ctrl.errorMessage, isNotNull);

        ctrl.clearError();
        expect(ctrl.errorMessage, isNull);
      });

      test('notifica listeners ao limpar erro', () async {
        await ctrl.login('', '');
        var notificacoes = 0;
        ctrl.addListener(() => notificacoes++);

        ctrl.clearError();
        expect(notificacoes, 1);
      });

      test('clearError sem erro anterior não lança exceção', () {
        expect(() => ctrl.clearError(), returnsNormally);
      });
    });
  });
}
