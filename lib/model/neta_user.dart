class NetaUser {
  NetaUser({
    this.id,
    this.token,
    this.username,
    this.avatar,
    this.phone,
  });

  int? id;
  String? username;
  String? avatar;
  String? phone;
  String? token;

  factory NetaUser.fromJson(Map<String, dynamic> json) => NetaUser(
        id: json["id"] ?? "",
        username: json["username"],
        avatar: json["avatar"] ?? "",
        phone: json["phone"],
        token: json["token"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "avatar": avatar ?? "",
        "phone": phone,
        "token": token ?? "",
      };
}
