class Customer {
  final String id;
  String name;
  String document;
  String phone;
  String email;
  String address;

  Customer({
    required this.id,
    required this.name,
    this.document = '',
    this.phone = '',
    this.email = '',
    this.address = '',
  });

  Customer copyWith({
    String? name,
    String? document,
    String? phone,
    String? email,
    String? address,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      document: document ?? this.document,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }
}
