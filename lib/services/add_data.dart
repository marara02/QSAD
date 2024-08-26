import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CloudFirestoreService {
  final FirebaseFirestore db;

  const CloudFirestoreService(this.db);

  Future<String> add(Map<String, dynamic> data) async {
    final document = await db.collection('drivingSession').add(data);
    return document.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getDrivingStory() {
    return db
        .collection('drivingSession')
        .where('username', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .orderBy('time', descending: true)
        .snapshots();
  }
}
