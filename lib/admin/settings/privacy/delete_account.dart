// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// Future<void> deleteUserAccountAndData({required String password}) async {
//   final auth = FirebaseAuth.instance;
//   final firestore = FirebaseFirestore.instance;
//   final user = auth.currentUser;

//   if (user == null) {
//     print("No user signed in");
//     return;
//   }

//   try {
//     final uid = user.uid;

//     // 🔐 Step 1: Reauthenticate (required before deleting Auth account)
//     final cred = EmailAuthProvider.credential(
//       email: user.email!,
//       password: password, // prompt user to enter again
//     );
//     await user.reauthenticateWithCredential(cred);

//     // 🔥 Step 2: Delete user document
//     await firestore.collection("users").doc(uid).delete();

//     // 🔥 Step 3: Delete prayers & comments
//     final prayers = await firestore
//         .collection("prayers")
//         .where("userId", isEqualTo: uid)
//         .get();
//     for (var doc in prayers.docs) {
//       final comments = await doc.reference.collection("comments").get();
//       for (var c in comments.docs) {
//         await c.reference.delete();
//       }
//       await doc.reference.delete();
//     }

//     // 🔥 Step 4: Delete testimonies & comments
//     final testimonies = await firestore
//         .collection("testimonies")
//         .where("userId", isEqualTo: uid)
//         .get();
//     for (var doc in testimonies.docs) {
//       final comments = await doc.reference.collection("comments").get();
//       for (var c in comments.docs) {
//         await c.reference.delete();
//       }
//       await doc.reference.delete();
//     }

//     // 🔥 Step 5: Delete videos & comments
//     final videos = await firestore
//         .collection("videos")
//         .where("userId", isEqualTo: uid)
//         .get();
//     for (var doc in videos.docs) {
//       final comments = await doc.reference.collection("comments").get();
//       for (var c in comments.docs) {
//         await c.reference.delete();
//       }
//       await doc.reference.delete();
//     }

//     // 🔥 Step 6: Delete Firebase Auth account
//     await user.delete();

//     print("✅ User and all related data deleted successfully");
//   } catch (e) {
//     print("❌ Error deleting account: $e");
//   }
// }



// 2
import 'package:firebase_auth/firebase_auth.dart';

class AccountService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        await user.delete(); // 🔥 deletes from Firebase Authentication
      }
    } catch (e) {
      // Sometimes Firebase requires recent login to delete account
      // So you may need to reauthenticate first
      print("Error deleting account: $e");
      throw Exception("Please re-login before deleting your account.");
    }
  }
}
