class User {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;
  final double monthlyBudget;
  final double savingsTarget;
  final DateTime createdAt;
  final String kycStatus;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    required this.monthlyBudget,
    this.savingsTarget = 0,
    required this.createdAt,
    this.kycStatus = 'NOT_STARTED',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profilePicture'],
      monthlyBudget: (json['monthlyBudget'] ?? 0).toDouble(),
      savingsTarget: (json['savingsTarget'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      kycStatus: json['kycStatus'] ?? 'NOT_STARTED',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'monthlyBudget': monthlyBudget,
      'savingsTarget': savingsTarget,
      'createdAt': createdAt.toIso8601String(),
      'kycStatus': kycStatus,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePicture,
    double? monthlyBudget,
    double? savingsTarget,
    DateTime? createdAt,
    String? kycStatus,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      savingsTarget: savingsTarget ?? this.savingsTarget,
      createdAt: createdAt ?? this.createdAt,
      kycStatus: kycStatus ?? this.kycStatus,
    );
  }
}
