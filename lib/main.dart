import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'data/repositories/rkeeper_repository_impl.dart';
import 'data/services/firebase_storage_service.dart';
import 'presentation/providers/rkeeper_provider.dart';
import 'presentation/rkeeper_app.dart';

// Import your generated firebase_options.dart here after running 'flutterfire configure'
// import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  // If you have already run 'flutterfire configure', use:
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Otherwise, use the default initialization:
  await Firebase.initializeApp();

  final storage = FirebaseStorageService();
  await storage.init();
  final repository = RKeeperRepositoryImpl(storage);

  runApp(
    ChangeNotifierProvider(
      create: (_) => RKeeperProvider(repository)..bootstrap(),
      child: const RKeeperApp(),
    ),
  );
}
