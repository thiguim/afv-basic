import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:afv_basico/controllers/app_controller.dart';

void main() {
  group('AppController', () {
    late AppController ctrl;

    setUp(() => ctrl = AppController());
    tearDown(() => ctrl.dispose());

    group('estado inicial', () {
      test('themeMode começa como ThemeMode.light', () {
        expect(ctrl.themeMode, ThemeMode.light);
      });

      test('isDark começa como false', () {
        expect(ctrl.isDark, isFalse);
      });
    });

    group('toggleTheme', () {
      test('de light para dark', () {
        ctrl.toggleTheme();
        expect(ctrl.themeMode, ThemeMode.dark);
        expect(ctrl.isDark, isTrue);
      });

      test('de dark volta para light', () {
        ctrl.toggleTheme(); // light → dark
        ctrl.toggleTheme(); // dark → light
        expect(ctrl.themeMode, ThemeMode.light);
        expect(ctrl.isDark, isFalse);
      });

      test('três alternâncias resultam em dark', () {
        ctrl.toggleTheme();
        ctrl.toggleTheme();
        ctrl.toggleTheme();
        expect(ctrl.isDark, isTrue);
      });

      test('notifica listeners ao alternar', () {
        var notificacoes = 0;
        ctrl.addListener(() => notificacoes++);

        ctrl.toggleTheme();
        expect(notificacoes, 1);

        ctrl.toggleTheme();
        expect(notificacoes, 2);
      });
    });
  });
}
