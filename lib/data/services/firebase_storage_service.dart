import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/errors/app_exception.dart';

class FirebaseStorageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String categoriesCollection = 'categories';
  static const String groupsCollection = 'groups';
  static const String itemsCollection = 'items';

  String get _userId {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw AppException('User must be logged in to access storage.');
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> _userCollection(String collectionName) {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection(collectionName);
  }

  Future<void> init() async {}

  Future<List<Map<String, dynamic>>> getAll(String collectionName) async {
    try {
      final snapshot = await _userCollection(collectionName).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (error) {
      throw AppException('Could not sync with cloud storage.', error);
    }
  }

  Future<void> put(String collectionName, String key, Map<String, dynamic> value) async {
    try {
      await _userCollection(collectionName).doc(key).set(value);
    } catch (error) {
      throw AppException('Could not save to cloud.', error);
    }
  }

  Future<void> delete(String collectionName, String key) async {
    try {
      await _userCollection(collectionName).doc(key).delete();
    } catch (error) {
      throw AppException('Could not delete from cloud.', error);
    }
  }
}
