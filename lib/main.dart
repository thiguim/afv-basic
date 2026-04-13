import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'controllers/app_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/customer_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/order_controller.dart';
import 'services/database_service.dart';
import 'repositories/sqlite/sqlite_customer_repository.dart';
import 'repositories/sqlite/sqlite_product_repository.dart';
import 'repositories/sqlite/sqlite_order_repository.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final db = DatabaseService.instance;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(
            create: (_) => CustomerController(SqliteCustomerRepository(db))),
        ChangeNotifierProvider(
            create: (_) => ProductController(SqliteProductRepository(db))),
        ChangeNotifierProvider(
            create: (_) => OrderController(SqliteOrderRepository(db))),
      ],
      child: const AFVApp(),
    ),
  );
}

class AFVApp extends StatelessWidget {
  const AFVApp({super.key});

  static const _seed = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<AppController>().themeMode;

    return MaterialApp(
      title: 'Landix Basic',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
