class Product {
  final String id;
  String name;
  String code;
  double price;
  String unit;

  Product({
    required this.id,
    required this.name,
    this.code = '',
    required this.price,
    this.unit = 'UN',
  });

  Product copyWith({
    String? name,
    String? code,
    double? price,
    String? unit,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      price: price ?? this.price,
      unit: unit ?? this.unit,
    );
  }
}
