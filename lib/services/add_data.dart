import 'package:cloud_firestore/cloud_firestore.dart';

class CloudFirestoreService{
  final FirebaseFirestore db;
  
  const CloudFirestoreService(this.db);
  
  Future<String> add(Map<String, dynamic> data) async{
    final document = await db.collection('drivingSession').add(data);
    return document.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getDrivingStory(){
    return db.collection('drivingSession').snapshots();
  }
}