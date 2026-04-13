import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/customer.dart';
import '../repositories/customer_repository.dart';

/// Gerencia o ciclo de vida dos clientes: listagem, busca e CRUD.
class CustomerController extends ChangeNotifier {
  CustomerController(this._repository) {
    _load();
  }

  final CustomerRepository _repository;
  static const _uuid = Uuid();

  List<Customer> _customers = [];

  List<Customer> get customers => List.unmodifiable(_customers);

  Future<void> _load() async {
    _customers = await _repository.getAll();
    notifyListeners();
  }

  /// Retorna clientes filtrados por nome, CPF/CNPJ ou telefone.
  List<Customer> search(String query) {
    if (query.isEmpty) return customers;
    final q = query.toLowerCase();
    return _customers
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.document.contains(q) ||
            c.phone.contains(q))
        .toList();
  }

  String generateId() => _uuid.v4();

  void add(Customer customer) async {
    await _repository.save(customer);
    _customers.add(customer);
    notifyListeners();
  }

  void update(Customer customer) async {
    await _repository.save(customer);
    final i = _customers.indexWhere((c) => c.id == customer.id);
    if (i != -1) {
      _customers[i] = customer;
      notifyListeners();
    }
  }

  void delete(String id) async {
    await _repository.delete(id);
    _customers.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
