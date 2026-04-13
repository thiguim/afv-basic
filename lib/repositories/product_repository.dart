import '../models/product.dart';

/// Contrato de acesso a dados de produtos.
/// Implementações concretas podem usar SQLite, API REST, memória, etc.
abstract class ProductRepository {
  /// Retorna todos os produtos.
  Future<List<Product>> getAll();

  /// Insere ou atualiza um produto (upsert por id).
  Future<void> save(Product product);

  /// Remove o produto com o [id] informado.
  Future<void> delete(String id);
}
