class AppUser {
  final String uid;
  final String email;
  final String name;
  final String username;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.username,
  });

  // convert app user -> json
  Map<String, dynamic> toJson() {
    return {'uid': uid, 'email': email, 'name': name, 'username': username};
  }

  // convert json -> app user
  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
      uid: jsonUser['uid'],
      email: jsonUser['email'],
      name: jsonUser['name'],
      username: jsonUser['username'] ?? '',
    );
  }
}
