import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:afv_basico/controllers/app_controller.dart';
import 'package:afv_basico/controllers/auth_controller.dart';
import 'package:afv_basico/controllers/customer_controller.dart';
import 'package:afv_basico/controllers/product_controller.dart';
import 'package:afv_basico/controllers/order_controller.dart';
import 'package:afv_basico/repositories/memory/memory_customer_repository.dart';
import 'package:afv_basico/repositories/memory/memory_product_repository.dart';
import 'package:afv_basico/repositories/memory/memory_order_repository.dart';

/// Wraps [child] in [MultiProvider] + [MaterialApp] com todos os controllers
/// necessários para testes de widgets de tela.
Widget testApp(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppController()),
      ChangeNotifierProvider(create: (_) => AuthController()),
      ChangeNotifierProvider(
          create: (_) => CustomerController(MemoryCustomerRepository())),
      ChangeNotifierProvider(
          create: (_) => ProductController(MemoryProductRepository())),
      ChangeNotifierProvider(
          create: (_) => OrderController(MemoryOrderRepository())),
    ],
    child: MaterialApp(home: child),
  );
}
