import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // The UID of the currently logged-in user
  final String myUid = FirebaseAuth.instance.currentUser!.uid;

  // STEP 1: Find user by ID
  Future<Map<String, dynamic>?> findUserByUniqueID(String friendID) async {
    var result = await _db
        .collection('users')
        .where('uniqueID', isEqualTo: friendID)
        .get();

    if (result.docs.isNotEmpty) {
      return result.docs.first.data(); // Return info if user found
    }
    return null; // Return null if not found
  }

  // STEP 2: Create a "Shared List" for both users
  Future<void> createSharedList(String friendUid, String listName) async {
    await _db.collection('shared_lists').add({
      'name': listName,
      'members': [myUid, friendUid], // Combine both UIDs
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // STEP 3: Get shared lists I'm part of (Stream)
  Stream<QuerySnapshot> get mySharedLists {
    return _db
        .collection('shared_lists')
        .where('members', arrayContains: myUid)
        .snapshots();
  }

  // STEP 4: Get tasks within a specific list
  Stream<QuerySnapshot> getTodos(String listId) {
    return _db
        .collection('shared_lists')
        .doc(listId)
        .collection('todos')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // STEP 5: Add new task to a specific list
  Future<void> addTodo(String listId, String title) async {
    await _db.collection('shared_lists').doc(listId).collection('todos').add({
      'title': title,
      'isDone': false,
      'createdBy': myUid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // STEP 6: Toggle task status (done/not done)
  Future<void> toggleTodoStatus(
    String listId,
    String todoId,
    bool currentStatus,
  ) async {
    await _db
        .collection('shared_lists')
        .doc(listId)
        .collection('todos')
        .doc(todoId)
        .update({'isDone': !currentStatus});
  }

  // --- PERSONAL TASKS ---

  // STEP 7: Get personal tasks
  Stream<QuerySnapshot> getPersonalTodos() {
    return _db
        .collection('users')
        .doc(myUid)
        .collection('personal_todos')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // STEP 8: Add personal task
  Future<void> addPersonalTodo(String title) async {
    await _db.collection('users').doc(myUid).collection('personal_todos').add({
      'title': title,
      'isDone': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // STEP 9: Toggle personal task status
  Future<void> togglePersonalStatus(String todoId, bool currentStatus) async {
    await _db
        .collection('users')
        .doc(myUid)
        .collection('personal_todos')
        .doc(todoId)
        .update({'isDone': !currentStatus});
  }

  // STEP 10: Delete personal task
  Future<void> deletePersonalTodo(String todoId) async {
    await _db
        .collection('users')
        .doc(myUid)
        .collection('personal_todos')
        .doc(todoId)
        .delete();
  }

  // --- SHARED LIST EXTRAS ---

  // STEP 11: Delete task (Shared List)
  Future<void> deleteTodo(String listId, String todoId) async {
    await _db
        .collection('shared_lists')
        .doc(listId)
        .collection('todos')
        .doc(todoId)
        .delete();
  }

  // STEP 12: Delete entire shared list
  Future<void> deleteSharedList(String listId) async {
    // Note: It's better to clean up subcollections, but deleting the doc works for simple cases.
    await _db.collection('shared_lists').doc(listId).delete();
  }

  // STEP 13: Fetch member emails
  Future<List<String>> getMemberEmails(List<dynamic> uids) async {
    List<String> emails = [];
    for (String uid in uids) {
      var doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        String? email = doc.data()?['email'];
        if (email != null) emails.add(email);
      }
    }
    return emails;
  }
}
