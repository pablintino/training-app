class UserInfo {
  final String? sub;
  final String? name;
  final String? nickname;
  final String? picture;
  final String? email;

  factory UserInfo.fromJson(Map<String, dynamic> parsedJson) {
    return UserInfo(
        sub: parsedJson['sub'],
        name: parsedJson['name'],
        nickname: parsedJson['nickname'],
        picture: parsedJson['picture'],
        email: parsedJson['email']);
  }

  UserInfo({this.sub, this.name, this.nickname, this.picture, this.email});
}
