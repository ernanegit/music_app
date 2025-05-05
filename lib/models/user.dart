class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final Location? location;
  final String profileImage;
  final String userType;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.location,
    required this.profileImage,
    required this.userType,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      location: json['location'] != null
          ? Location.fromJson(json['location'])
          : null,
      profileImage: json['profileImage'] ?? 'default-profile.jpg',
      userType: json['userType'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'location': location?.toJson(),
      'profileImage': profileImage,
      'userType': userType,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Location {
  final String? city;
  final String? state;
  final String country;

  Location({
    this.city,
    this.state,
    this.country = 'Brasil',
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      city: json['city'],
      state: json['state'],
      country: json['country'] ?? 'Brasil',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'state': state,
      'country': country,
    };
  }
}
