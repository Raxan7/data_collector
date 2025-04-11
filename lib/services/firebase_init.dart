import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseInitializer {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (!_initialized) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        _initialized = true;
      } catch (e) {
        // Handle the case where DefaultFirebaseOptions is not configured for Linux
        if (e.toString().contains('DefaultFirebaseOptions')) {
          throw UnsupportedError(
              'DefaultFirebaseOptions have not been configured for this platform. '
              'Please run the FlutterFire CLI to configure Firebase for your project.');
        } else {
          rethrow;
        }
      }
    }
  }
}