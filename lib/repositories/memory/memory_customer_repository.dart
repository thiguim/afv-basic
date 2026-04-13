import '../../models/customer.dart';
import '../customer_repository.dart';

/// Implementação em memória do [CustomerRepository].
/// Utilizada enquanto não há persistência real (SQLite / API).
class MemoryCustomerRepository implements CustomerRepository {
  final List<Customer> _data = [
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

  @override
  Future<List<Customer>> getAll() async => List.of(_data);

  @override
  Future<void> save(Customer customer) async {
    final i = _data.indexWhere((c) => c.id == customer.id);
    if (i != -1) {
      _data[i] = customer;
    } else {
      _data.add(customer);
    }
  }

  @override
  Future<void> delete(String id) async {
    _data.removeWhere((c) => c.id == id);
  }
}
