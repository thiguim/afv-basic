import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:afv_basico/controllers/app_controller.dart';
import 'package:afv_basico/controllers/auth_controller.dart';
import 'package:afv_basico/screens/login_screen.dart';

// LoginScreen só precisa de AppController e AuthController
Widget _wrap() => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
      ],
      child: const MaterialApp(home: LoginScreen()),
    );

/// Pump helper que expande o viewport para caber o rodapé e o botão Entrar.
Future<void> _pumpLogin(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 1100);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(_wrap());
  await tester.pumpAndSettle();
}

void main() {
  group('LoginScreen', () {
    testWidgets('renderiza sem erros', (tester) async {
      await _pumpLogin(tester);
    });

    testWidgets('exibe nome do app "Landix Basic"', (tester) async {
      await _pumpLogin(tester);
      expect(find.text('Landix Basic'), findsOneWidget);
    });

    testWidgets('exibe subtítulo "Força de Vendas"', (tester) async {
      await _pumpLogin(tester);
      expect(find.text('Força de Vendas'), findsOneWidget);
    });

    testWidgets('exibe ícone do app (storefront)', (tester) async {
      await _pumpLogin(tester);
      expect(find.byIcon(Icons.storefront_rounded), findsOneWidget);
    });

    testWidgets('exibe campo de E-mail', (tester) async {
      await _pumpLogin(tester);
      expect(find.widgetWithText(TextFormField, 'E-mail'), findsOneWidget);
    });

    testWidgets('exibe campo de Senha', (tester) async {
      await _pumpLogin(tester);
      expect(find.widgetWithText(TextFormField, 'Senha'), findsOneWidget);
    });

    testWidgets('exibe botão FilledButton Entrar', (tester) async {
      await _pumpLogin(tester);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('exibe rodapé com versão "Landix Basic v1.0"', (tester) async {
      await _pumpLogin(tester);
      expect(find.text('Landix Basic v1.0'), findsOneWidget);
    });

    testWidgets('exibe link "Esqueci minha senha"', (tester) async {
      await _pumpLogin(tester);
      expect(find.text('Esqueci minha senha'), findsOneWidget);
    });

    testWidgets('validação: e-mail vazio exibe mensagem de erro', (tester) async {
      await _pumpLogin(tester);
      // Toca no botão sem preencher nenhum campo
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(find.text('Informe o e-mail'), findsOneWidget);
    });

    testWidgets('validação: senha vazia exibe mensagem de erro', (tester) async {
      await _pumpLogin(tester);
      // Preenche apenas o e-mail
      await tester.enterText(
          find.widgetWithText(TextFormField, 'E-mail'), 'vendedor@email.com');
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(find.text('Informe a senha'), findsOneWidget);
    });

    testWidgets('senha é obscurecida por padrão (ícone de mostrar)', (tester) async {
      await _pumpLogin(tester);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('toque no ícone de visibilidade alterna para "ocultar senha"', (tester) async {
      await _pumpLogin(tester);
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('segundo toque no ícone volta para "mostrar senha"', (tester) async {
      await _pumpLogin(tester);
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('exibe ícone de e-mail no campo', (tester) async {
      await _pumpLogin(tester);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('exibe ícone de cadeado no campo de senha', (tester) async {
      await _pumpLogin(tester);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });
  });
}
