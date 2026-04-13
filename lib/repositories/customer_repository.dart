import '../models/customer.dart';

/// Contrato de acesso a dados de clientes.
/// Implementações concretas podem usar SQLite, API REST, memória, etc.
abstract class CustomerRepository {
  /// Retorna todos os clientes.
  Future<List<Customer>> getAll();

  /// Insere ou atualiza um cliente (upsert por id).
  Future<void> save(Customer customer);

  /// Remove o cliente com o [id] informado.
  Future<void> delete(String id);
}
