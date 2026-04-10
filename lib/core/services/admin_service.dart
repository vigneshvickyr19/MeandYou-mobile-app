import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/admin_settings_model.dart';
import '../constants/firebase_constants.dart';
import 'notification_api_service.dart';

class AdminService {
  static final AdminService _instance = AdminService._();
  static AdminService get instance => _instance;

  AdminService._();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // Collection reference
  DocumentReference get _adminSettingsDoc =>
      _db.collection(FirebaseConstants.admin).doc(FirebaseConstants.settings);
  CollectionReference get _helpCenterCollection =>
      _db.collection(FirebaseConstants.helpCenter);
  CollectionReference get _announcementsCollection =>
      _db.collection(FirebaseConstants.announcements);

  // Stream of settings
  Stream<AdminSettings> streamSettings() {
    return _adminSettingsDoc.snapshots().map((doc) {
      if (doc.exists) {
        return AdminSettings.fromMap(doc.data() as Map<String, dynamic>);
      }
      return AdminSettings(updatedAt: DateTime.now());
    });
  }

  // Fetch settings once
  Future<AdminSettings> getSettings() async {
    final doc = await _adminSettingsDoc.get();
    if (doc.exists) {
      return AdminSettings.fromMap(doc.data() as Map<String, dynamic>);
    }
    return AdminSettings(updatedAt: DateTime.now());
  }

  // Update settings
  Future<void> updateSettings(AdminSettings settings) async {
    await _adminSettingsDoc.set({
      ...settings.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Help Center
  Stream<List<Map<String, dynamic>>> streamHelpContent() {
    return _helpCenterCollection.orderBy('index').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    });
  }

  Future<void> updateHelpItem(String id, Map<String, dynamic> data) async {
    await _helpCenterCollection.doc(id).set(data, SetOptions(merge: true));
  }

  Future<void> deleteHelpItem(String id) async {
    await _helpCenterCollection.doc(id).delete();
  }

  // Announcements
  Future<void> createAnnouncement(Announcement announcement) async {
    await _announcementsCollection.add({
      ...announcement.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Trigger Individual Push Notifications
    try {
      final Query query = _db.collection(FirebaseConstants.users);
      QuerySnapshot usersSnapshot;

      if (announcement.targetAudience == 'male') {
        usersSnapshot = await query.where('gender', isEqualTo: 'male').get();
      } else if (announcement.targetAudience == 'female') {
        usersSnapshot = await query.where('gender', isEqualTo: 'female').get();
      } else {
        usersSnapshot = await query.get();
      }

      for (var doc in usersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String? fcmToken = data[FirebaseConstants.fcmToken];
        
        if (fcmToken != null && fcmToken.isNotEmpty) {
          NotificationApiService.instance.sendNotification(
            deviceToken: fcmToken,
            title: announcement.title,
            body: announcement.message,
            data: {
              'type': 'announcement',
              'announcementId': announcement.id,
              'targetAudience': announcement.targetAudience,
            },
          ).catchError((e) {
            debugPrint('Error sending notification to user ${doc.id}: $e');
          });
        }
      }
      debugPrint('Announcement processing complete for ${usersSnapshot.docs.length} candidate users.');
    } catch (e) {
      debugPrint('Error processing announcement notifications: $e');
    }
  }

  Stream<List<Announcement>> streamAnnouncements() {
    return _announcementsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    Announcement.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();
        });
  }
}
