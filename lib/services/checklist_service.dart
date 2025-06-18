import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/checklist_item.dart';

class ChecklistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SharedPreferences _prefs;
  static const String _localChecklistKey = 'local_checklist';

  ChecklistService(this._prefs);

  // Get checklist items from Firestore
  Stream<List<ChecklistItem>> getChecklistItems(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('checklist')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChecklistItem.fromFirestore(doc)).toList();
    });
  }

  // Add a new checklist item
  Future<void> addChecklistItem(String userId, ChecklistItem item) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('checklist')
        .add(item.toFirestore());
    await _saveToLocalStorage(userId);
  }

  // Update a checklist item
  Future<void> updateChecklistItem(String userId, ChecklistItem item) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('checklist')
        .doc(item.id)
        .update(item.toFirestore());
    await _saveToLocalStorage(userId);
  }

  // Delete a checklist item
  Future<void> deleteChecklistItem(String userId, String itemId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('checklist')
        .doc(itemId)
        .delete();
    await _saveToLocalStorage(userId);
  }

  // Save checklist to local storage
  Future<void> _saveToLocalStorage(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('checklist')
        .get();
    
    final items = snapshot.docs
        .map((doc) => ChecklistItem.fromFirestore(doc))
        .map((item) => item.toJson())
        .toList();
    
    await _prefs.setString(_localChecklistKey, jsonEncode(items));
  }

  // Get checklist from local storage
  List<ChecklistItem> getLocalChecklist() {
    final String? jsonString = _prefs.getString(_localChecklistKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) {
      final data = Map<String, dynamic>.from(json);
      return ChecklistItem.fromJson(data);
    }).toList();
  }

  // Initialize default checklist items
  Future<void> initializeDefaultChecklist(String userId) async {
    final defaultItems = [
      ChecklistItem(
        id: '1',
        title: 'Visa Documents',
        description: 'Passport, visa application, photos',
        createdAt: DateTime.now(),
      ),
      ChecklistItem(
        id: '2',
        title: 'Vaccination Proof',
        description: 'COVID-19 and other required vaccinations',
        createdAt: DateTime.now(),
      ),
      ChecklistItem(
        id: '3',
        title: 'Ihram Clothes',
        description: 'Two white unsewn pieces of cloth for men',
        createdAt: DateTime.now(),
      ),
      ChecklistItem(
        id: '4',
        title: 'Ihram Intention',
        description: 'Learn and prepare your intention for Ihram',
        createdAt: DateTime.now(),
      ),
      ChecklistItem(
        id: '5',
        title: 'Ziyarat Plan',
        description: 'Plan your visits to historical sites',
        createdAt: DateTime.now(),
      ),
    ];

    final batch = _firestore.batch();
    final checklistRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('checklist');

    for (var item in defaultItems) {
      final docRef = checklistRef.doc();
      batch.set(docRef, item.toFirestore());
    }

    await batch.commit();
    await _saveToLocalStorage(userId);
  }

  Future<void> reorderChecklist(String userId, List<ChecklistItem> reorderedItems) async {
    final batch = _firestore.batch();
    final checklistRef = _firestore.collection('users').doc(userId).collection('checklist');
    for (int i = 0; i < reorderedItems.length; i++) {
      final item = reorderedItems[i];
      final docRef = checklistRef.doc(item.id);
      // Option 1: update a 'position' field (recommended for large lists)
      // Option 2: update createdAt to preserve order (simple for now)
      batch.update(docRef, {'createdAt': DateTime.now().add(Duration(milliseconds: i)).toIso8601String()});
    }
    await batch.commit();
    await _saveToLocalStorage(userId);
  }
} 