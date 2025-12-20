class AppUser {
  final String uid;
  final String nickname;
  final String? iconUrl;
  final int userColor;
  final String visibility; // public / postOnly / private
  final Map<String, String> snsLinks;

  AppUser({
    required this.uid,
    required this.nickname,
    this.iconUrl,
    required this.userColor,
    required this.visibility,
    required this.snsLinks,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      nickname: (data['nickname'] ?? 'ななし') as String,
      iconUrl: data['iconUrl'] as String?,
      userColor: (data['userColor'] ?? 0xFF9E9E9E) as int,
      visibility: (data['visibility'] ?? 'postOnly') as String,
      snsLinks: Map<String, String>.from((data['snsLinks'] ?? {}) as Map),
    );
  }

  Map<String, dynamic> toMap() => {
    'nickname': nickname,
    'iconUrl': iconUrl,
    'userColor': userColor,
    'visibility': visibility,
    'snsLinks': snsLinks,
  };
}
