class AppUser {
  final String uid;
  final String nickname;
  final String? iconUrl;
  final String visibility; // public / postOnly / private
  final Map<String, String> snsLinks;

  AppUser({
    required this.uid,
    required this.nickname,
    this.iconUrl,
    required this.visibility,
    required this.snsLinks,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      nickname: (data['nickname'] ?? 'ななし') as String,
      iconUrl: data['iconUrl'] as String?,
      visibility: (data['visibility'] ?? 'postOnly') as String,
      snsLinks: Map<String, String>.from((data['snsLinks'] ?? {}) as Map),
    );
  }

  Map<String, dynamic> toMap() => {
        'nickname': nickname,
        'iconUrl': iconUrl,
        'visibility': visibility,
        'snsLinks': snsLinks,
      };
}
