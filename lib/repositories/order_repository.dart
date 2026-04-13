import '../models/order.dart';

/// Contrato de acesso a dados de pedidos.
/// Implementações concretas podem usar SQLite, API REST, memória, etc.
abstract class OrderRepository {
  /// Retorna todos os pedidos.
  Future<List<Order>> getAll();

  /// Insere ou atualiza um pedido (upsert por id).
  /// Retorna o IDPEDI definitivo — gerado pelo banco no INSERT ou o próprio no UPDATE.
  Future<int> save(Order order);

  /// Atualiza apenas o status de um pedido.
  Future<void> updateStatus(int id, OrderStatus status);

  /// Remove o pedido com o [id] informado.
  Future<void> delete(int id);
}
