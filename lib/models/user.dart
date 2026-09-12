class User {
  final int id;
  final String userName;
  final String firstName;
  final String lastName;
  final String email;
  final String profileImageUrl;

  const User({
    required this.id,
    required this.userName,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.profileImageUrl = '',
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? userName : name;
  }

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: (json['id'] as num).toInt(),
    userName: json['username'] as String,
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    email: json['email'] as String? ?? '',
    profileImageUrl: json['image'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': userName,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'image': profileImageUrl,
  };
}
