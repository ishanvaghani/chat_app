import 'package:chat_ui/services/firebase_services.dart';

// Get All Users
FirebaseServices _firebaseServices = FirebaseServices();

Future<void> addToFavorite(String? userId) async {
  List<dynamic> _favorites = [];
  await _firebaseServices.userRef
      .doc(_firebaseServices.currentUserId)
      .get()
      .then((snapshot) {
    Map<dynamic, dynamic> values = snapshot.data()!;
    _favorites.addAll(values['favoriteUsers']);
  });
  Map<String, dynamic> favoriteMap = {
    'favoriteUsers': _favorites,
  };
  _favorites.add(userId);
  await _firebaseServices.userRef
      .doc(_firebaseServices.currentUserId)
      .update(favoriteMap);
}

Future<void> removeFromFavorite(String? userId) async {
  List<dynamic> _favorites = [];
  await _firebaseServices.userRef
      .doc(_firebaseServices.currentUserId)
      .get()
      .then((snapshot) {
    Map<dynamic, dynamic> values = snapshot.data()!;
    _favorites.addAll(values['favoriteUsers']);
  });
  _favorites.remove(userId);
  Map<String, dynamic> favoriteMap = {
    'favoriteUsers': _favorites,
  };
  await _firebaseServices.userRef
      .doc(_firebaseServices.currentUserId)
      .update(favoriteMap);
}

Future<bool> checkFavorite(String? userId) async {
  bool _isFavorite = false;
  await _firebaseServices.userRef
      .doc(_firebaseServices.currentUserId)
      .get()
      .then((snapshot) {
    Map<dynamic, dynamic> values = snapshot.data()!;
    List<dynamic> _favorites = values['favoriteUsers'];
    if(_favorites.contains(userId)) {
      _isFavorite = true;
    }
  });
  return _isFavorite;
}

Future<void> blockUser(String? userId) async {
  List<dynamic> _blockeUsers = [];
  await _firebaseServices.userRef
      .doc(_firebaseServices.currentUserId)
      .get()
      .then((snapshot) {
    Map<dynamic, dynamic> values = snapshot.data()!;
    _blockeUsers.addAll(values['blockedUsers']);
  });
  Map<String, dynamic> favoriteMap = {
    'blockedUsers': _blockeUsers,
  };
  _blockeUsers.add(userId);
  await _firebaseServices.userRef
      .doc(_firebaseServices.currentUserId)
      .update(favoriteMap);
}

Future<void> unblockUser(String? userId) async {
  List<dynamic> _blockeUsers = [];
  await _firebaseServices.userRef
      .doc(_firebaseServices.currentUserId)
      .get()
      .then((snapshot) {
    Map<dynamic, dynamic> values = snapshot.data()!;
    _blockeUsers.addAll(values['blockedUsers']);
  });
  _blockeUsers.remove(userId);
  Map<String, dynamic> favoriteMap = {
    'blockedUsers': _blockeUsers,
  };
  await _firebaseServices.userRef
      .doc(_firebaseServices.currentUserId)
      .update(favoriteMap);
}

Future<bool> checkBlocked(String? userId) async {
  bool _isBlocked = false;
  await _firebaseServices.userRef
      .doc(_firebaseServices.currentUserId)
      .get()
      .then((snapshot) {
    Map<dynamic, dynamic> values = snapshot.data()!;
    List<dynamic> _blockeUsers = values['blockedUsers'];
    if(_blockeUsers.contains(userId)) {
      _isBlocked = true;
    }
  });
  return _isBlocked;
}

Future<bool> checkMeBlocked(String? userId) async {
  bool _isBlocked = false;
  await _firebaseServices.userRef
      .doc(userId)
      .get()
      .then((snapshot) {
    Map<dynamic, dynamic> values = snapshot.data()!;
    List<dynamic> _blockeUsers = values['blockedUsers'];
    if(_blockeUsers.contains(_firebaseServices.currentUserId)) {
      _isBlocked = true;
    }
  });
  return _isBlocked;
}