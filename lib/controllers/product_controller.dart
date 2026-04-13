import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';

/// Gerencia o ciclo de vida dos produtos: listagem, busca e CRUD.
class ProductController extends ChangeNotifier {
  ProductController(this._repository) {
    _load();
  }

  final ProductRepository _repository;
  static const _uuid = Uuid();

  List<Product> _products = [];

  List<Product> get products => List.unmodifiable(_products);

  Future<void> _load() async {
    _products = await _repository.getAll();
    notifyListeners();
  }

  /// Retorna produtos filtrados por nome ou código.
  List<Product> search(String query) {
    if (query.isEmpty) return products;
    final q = query.toLowerCase();
    return _products
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.code.toLowerCase().contains(q))
        .toList();
  }

  String generateId() => _uuid.v4();

  void add(Product product) async {
    await _repository.save(product);
    _products.add(product);
    notifyListeners();
  }

  void update(Product product) async {
    await _repository.save(product);
    final i = _products.indexWhere((p) => p.id == product.id);
    if (i != -1) {
      _products[i] = product;
      notifyListeners();
    }
  }

  void delete(String id) async {
    await _repository.delete(id);
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
