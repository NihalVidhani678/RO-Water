class Admin {
  String id;
  String username;
  String email;
  String name;

  Admin({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "email": email,
      "name": name,
    };
  }
}
