class Client {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final DateTime? createdAt;

  Client({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.createdAt,
  });

  factory Client.fromMap(Map<String, dynamic> map) => Client(
    id: map['id'] as String,
    name: map['name'] as String,
    phone: map['phone'] as String,
    email: map['email'] as String?,
    createdAt: map['created_at'] != null
        ? DateTime.parse(map['created_at'] as String)
        : null,
  );
}
