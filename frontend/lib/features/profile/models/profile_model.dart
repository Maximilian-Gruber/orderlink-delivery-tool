class Profile {
  final String employeeId;
  final String email;
  final String firstName;
  final String lastName;
  final String role;

  Profile({
    required this.employeeId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      employeeId: json['employeeId'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: json['role'] ?? '',
    );
  }
}