class UserModel {
  String? id;
  String name;
  String email;
  String phone;
  String bloodGroup;
  DateTime? createdAt;
  String? address;
  bool isDonor;
  bool isAvailable;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.bloodGroup,
    this.createdAt,
    this.address,
    required this.isDonor,
    required this.isAvailable,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      bloodGroup: json['blood_group'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : null,
      address: json['address'],
      isDonor: json['is_donor'] ?? true,
      isAvailable: json['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'blood_group': bloodGroup,
      'created_at': createdAt?.toIso8601String(),
      'address': address,
      'is_donor': isDonor,
      'is_available': isAvailable,
    };
  }
}