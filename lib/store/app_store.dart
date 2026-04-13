import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../models/payment_condition.dart';
import '../models/order.dart';

class AppStore extends ChangeNotifier {
  static const _uuid = Uuid();

  // ── Tema ──────────────────────────────────────────────────────────────────

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // ── Dados ─────────────────────────────────────────────────────────────────

  final List<Customer> _customers = [
    Customer(
      id: 'c1',
      name: 'João Silva',
      document: '123.456.789-00',
      phone: '(11) 98765-4321',
      email: 'joao.silva@email.com',
      address: 'Rua das Flores, 123 - São Paulo/SP',
    ),
    Customer(
      id: 'c2',
      name: 'Maria Souza',
      document: '987.654.321-00',
      phone: '(11) 91234-5678',
      email: 'maria.souza@email.com',
      address: 'Av. Paulista, 456 - São Paulo/SP',
    ),
    Customer(
      id: 'c3',
      name: 'Empresa Carlos Ltda',
      document: '12.345.678/0001-90',
      phone: '(11) 3456-7890',
      email: 'contato@carlosltda.com.br',
      address: 'Rua Comercial, 789 - São Paulo/SP',
    ),
    Customer(
      id: 'c4',
      name: 'Ana Ferreira',
      document: '456.789.123-00',
      phone: '(21) 99876-5432',
      email: 'ana.ferreira@email.com',
      address: 'Rua das Palmeiras, 321 - Rio de Janeiro/RJ',
    ),
  ];

  final List<Product> _products = [
    Product(id: 'p1', name: 'Notebook Dell Inspiron', code: 'NB001', price: 3499.99, unit: 'UN'),
    Product(id: 'p2', name: 'Mouse Wireless Logitech', code: 'MS001', price: 89.90, unit: 'UN'),
    Product(id: 'p3', name: 'Teclado Mecânico Redragon', code: 'TC001', price: 299.90, unit: 'UN'),
    Product(id: 'p4', name: 'Monitor LED 24"', code: 'MN001', price: 1199.99, unit: 'UN'),
    Product(id: 'p5', name: 'Cabo HDMI 2m', code: 'CB001', price: 29.90, unit: 'UN'),
    Product(id: 'p6', name: 'SSD 480GB Kingston', code: 'SD001', price: 349.90, unit: 'UN'),
    Product(id: 'p7', name: 'Memória RAM 8GB DDR4', code: 'MR001', price: 189.90, unit: 'UN'),
    Product(id: 'p8', name: 'Webcam Full HD', code: 'WC001', price: 249.90, unit: 'UN'),
  ];

  static const List<PaymentCondition> _paymentConditions = [
    PaymentCondition(id: 'pc1', name: 'À Vista', days: 0, interestRate: 0),
    PaymentCondition(id: 'pc2', name: '30 dias', days: 30, interestRate: 0),
    PaymentCondition(id: 'pc3', name: '2x sem juros', days: 30, interestRate: 0),
    PaymentCondition(id: 'pc4', name: '3x com juros (2%)', days: 30, interestRate: 2.0),
    PaymentCondition(id: 'pc5', name: '6x com juros (3,5%)', days: 30, interestRate: 3.5),
    PaymentCondition(id: 'pc6', name: '30/60/90 dias', days: 30, interestRate: 0),
  ];

  final List<Order> _orders = [];

  // ── Getters ──────────────────────────────────────────────────────────────

  List<Customer> get customers => List.unmodifiable(_customers);
  List<Product> get products => List.unmodifiable(_products);
  List<PaymentCondition> get paymentConditions => List.unmodifiable(_paymentConditions);
  List<Order> get orders => List.unmodifiable(_orders);

  // ── Customer CRUD ─────────────────────────────────────────────────────────

  void addCustomer(Customer c) {
    _customers.add(c);
    notifyListeners();
  }

  void updateCustomer(Customer c) {
    final i = _customers.indexWhere((x) => x.id == c.id);
    if (i != -1) {
      _customers[i] = c;
      notifyListeners();
    }
  }

  void deleteCustomer(String id) {
    _customers.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // ── Product CRUD ──────────────────────────────────────────────────────────

  void addProduct(Product p) {
    _products.add(p);
    notifyListeners();
  }

  void updateProduct(Product p) {
    final i = _products.indexWhere((x) => x.id == p.id);
    if (i != -1) {
      _products[i] = p;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // ── Order CRUD ────────────────────────────────────────────────────────────

  void addOrder(Order o) {
    _orders.insert(0, o);
    notifyListeners();
  }

  void updateOrderStatus(String id, OrderStatus status) {
    final o = _orders.firstWhere((x) => x.id == id);
    o.status = status;
    notifyListeners();
  }

  void deleteOrder(String id) {
    _orders.removeWhere((o) => o.id == id);
    notifyListeners();
  }

  // ── Stats ─────────────────────────────────────────────────────────────────

  double get monthlyRevenue {
    final now = DateTime.now();
    return _orders
        .where((o) =>
            o.createdAt.month == now.month &&
            o.createdAt.year == now.year &&
            o.status != OrderStatus.cancelled)
        .fold(0.0, (s, o) => s + o.total);
  }

  int get monthlyOrdersCount {
    final now = DateTime.now();
    return _orders
        .where((o) =>
            o.createdAt.month == now.month && o.createdAt.year == now.year)
        .length;
  }

  List<Order> get recentOrders => _orders.take(5).toList();

  // ── Helpers ───────────────────────────────────────────────────────────────

  String generateId() => _uuid.v4();
}
