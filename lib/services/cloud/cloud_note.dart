import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynote/services/cloud/cloud_storage_constants.dart';

class CloudNote {
  final String documentId;
  final String text;
  final String ownerUserId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CloudNote({
    required this.documentId,
    required this.text,
    required this.ownerUserId,
    required this.createdAt,
    required this.updatedAt,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
    : documentId = snapshot.id,
      text = snapshot.data()[textFieldName] as String,
      ownerUserId = snapshot.data()[ownerUserIdFieldName] as String,
      createdAt = (snapshot.data()[createdAtFieldName] as Timestamp?)?.toDate(),
      updatedAt = (snapshot.data()[updatedAtFieldName] as Timestamp?)?.toDate();
}
