import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:mynote/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudNote {
  final String documentId;
  final String text;
  final String ownerUserId;

  const CloudNote({
    required this.documentId,
    required this.text,
    required this.ownerUserId,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
    : documentId = snapshot.id,
      text = snapshot.data()[textFieldName] as String,
      ownerUserId = snapshot.data()[ownerUserIdFieldName] as String;
}
