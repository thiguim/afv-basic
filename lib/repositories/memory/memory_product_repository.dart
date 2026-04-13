import '../../models/product.dart';
import '../product_repository.dart';

/// Implementação em memória do [ProductRepository].
/// Utilizada enquanto não há persistência real (SQLite / API).
class MemoryProductRepository implements ProductRepository {
  final List<Product> _data = [
    Product(id: 'p1', name: 'Notebook Dell Inspiron', code: 'NB001', price: 3499.99, unit: 'UN'),
    Product(id: 'p2', name: 'Mouse Wireless Logitech', code: 'MS001', price: 89.90, unit: 'UN'),
    Product(id: 'p3', name: 'Teclado Mecânico Redragon', code: 'TC001', price: 299.90, unit: 'UN'),
    Product(id: 'p4', name: 'Monitor LED 24"', code: 'MN001', price: 1199.99, unit: 'UN'),
    Product(id: 'p5', name: 'Cabo HDMI 2m', code: 'CB001', price: 29.90, unit: 'UN'),
    Product(id: 'p6', name: 'SSD 480GB Kingston', code: 'SD001', price: 349.90, unit: 'UN'),
    Product(id: 'p7', name: 'Memória RAM 8GB DDR4', code: 'MR001', price: 189.90, unit: 'UN'),
    Product(id: 'p8', name: 'Webcam Full HD', code: 'WC001', price: 249.90, unit: 'UN'),
  ];

  @override
  Future<List<Product>> getAll() async => List.of(_data);

  @override
  Future<void> save(Product product) async {
    final i = _data.indexWhere((p) => p.id == product.id);
    if (i != -1) {
      _data[i] = product;
    } else {
      _data.add(product);
    }
  }

  @override
  Future<void> delete(String id) async {
    _data.removeWhere((p) => p.id == id);
  }
}
