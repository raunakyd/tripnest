import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: "AIzaSyCo1OJ8Uh7n-aGj63mAtct5Zy452IDP2T0", // 🔹 Replace with actual API key from Firebase
      authDomain: "tripnest-fcd82.firebaseapp.com",
      projectId: "tripnest-fcd82",
      storageBucket: "tripnest-fcd82.appspot.com",
      messagingSenderId: "1039513210319",
      appId: "1:1039513210319:android:ad7f2e12bacc2c5acf16ba",

    );
  }
}
