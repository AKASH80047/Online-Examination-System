import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyAh2ItBaYrgMYFgiVAt4vOAxIBGIlN0A_0',
        appId: '1:66705521417:android:c6e78fcfb5256e6b8631d8',
        messagingSenderId: '66705521417',
        projectId: 'exam-paper-87314',
        authDomain: 'exam-paper-87314.firebaseapp.com',
        storageBucket: 'exam-paper-87314.firebasestorage.app',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'AIzaSyAh2ItBaYrgMYFgiVAt4vOAxIBGIlN0A_0',
          appId: '1:66705521417:android:c6e78fcfb5256e6b8631d8',
          messagingSenderId: '66705521417',
          projectId: 'exam-paper-87314',
          storageBucket: 'exam-paper-87314.firebasestorage.app',
        );
      case TargetPlatform.iOS:
        return const FirebaseOptions(
          apiKey: 'AIzaSyAh2ItBaYrgMYFgiVAt4vOAxIBGIlN0A_0',
          appId: '1:66705521417:ios:c6e78fcfb5256e6b8631d8',
          messagingSenderId: '66705521417',
          projectId: 'exam-paper-87314',
          storageBucket: 'exam-paper-87314.firebasestorage.app',
          iosBundleId: 'com.example.examPaper',
        );
      default:
        throw UnsupportedError('Platform not supported.');
    }
  }
}
