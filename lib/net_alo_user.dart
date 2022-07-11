class NetAloUser {
  NetAloUser({this.id, this.token, this.username, this.avatar, this.phone, this.isAdmin});

  num? id;
  String? username;
  String? avatar;
  String? phone;
  String? token;
  bool? isAdmin;

  factory NetAloUser.fromJson(Map<String, dynamic> json) => NetAloUser(
        id: json["id"] ?? 0,
        username: json["username"],
        avatar: json["avatar"] ?? "",
        phone: json["phone"],
        token: json["token"] ?? "",
        isAdmin: json["isAdmin"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "avatar": avatar ?? "",
        "phone": phone,
        "token": token ?? "",
        "isAdmin": isAdmin ?? "",
      };

  bool get isEnoughBasicInfo => id != null && phone != null;
}
