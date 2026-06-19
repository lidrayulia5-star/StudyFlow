import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference activities =
      FirebaseFirestore.instance.collection('activities');

  Future<void> addActivity({
    required String judul,
    required String mataKuliah,
    required String kategori,
    required String status,
    required String deadline,
    required String catatan,
  }) async {
    await activities.add({
      'judul': judul,
      'mataKuliah': mataKuliah,
      'kategori': kategori,
      'status': status,
      'deadline': deadline,
      'catatan': catatan,
      'createdAt': Timestamp.now(),
    });
  }
}