// lib/providers/mail_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MailProvider with ChangeNotifier {
  final List<QueryDocumentSnapshot> _mails = [];
  List<QueryDocumentSnapshot> _filteredMails = [];

  List<QueryDocumentSnapshot> get mails => _filteredMails;

  MailProvider() {
    _fetchMails();
  }

  void _fetchMails() {
    FirebaseFirestore.instance
        .collection('contact_messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _mails.clear();
      _mails.addAll(snapshot.docs);
      _filteredMails = List.from(_mails);
      notifyListeners();
    });
  }

  void filterMails(String query) {
    final lowerQuery = query.toLowerCase();
    _filteredMails = _mails.where((mail) {
      final data = mail.data() as Map<String, dynamic>;
      return data['name']?.toLowerCase().contains(lowerQuery) == true ||
          data['message']?.toLowerCase().contains(lowerQuery) == true;
    }).toList();
    notifyListeners();
  }

  Future<void> markAsRead(String mailId) async {
    await FirebaseFirestore.instance
        .collection('contact_messages')
        .doc(mailId)
        .update({'isRead': true});
  }
}
