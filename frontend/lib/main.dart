import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'views/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


Future<bool> checkInternetConnection() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}

Future<void> initializeFirebase() async {
  int maxRetries = 3;
  int currentRetry = 0;

  while (currentRetry < maxRetries) {
    try {
      // Check internet connectivity first
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) {
        throw Exception('No internet connection');
      }

      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Configure Firestore settings
      FirebaseFirestore.instance.settings = Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // Test connection with a simple operation
      await FirebaseFirestore.instance
          .collection('test')
          .doc('connection_test')
          .get()
          .timeout(const Duration(seconds: 10));

      print('Firebase initialized successfully');
      return;
    } catch (e) {
      currentRetry++;
      print('Firebase connection attempt $currentRetry failed: $e');

      if (currentRetry < maxRetries) {
        // Exponential backoff with jitter
        final backoffDuration = Duration(
          milliseconds: (pow(2, currentRetry) * 1000).toInt() +
              Random().nextInt(1000),
        );
        await Future.delayed(backoffDuration);

        // Reset Firestore instance
        await FirebaseFirestore.instance.terminate();
        await FirebaseFirestore.instance.clearPersistence();
      } else {
        print('Failed to connect to Firebase after $maxRetries attempts');
        rethrow;
      }
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isInitialized = false;
  int maxRetries = 3;
  int currentRetry = 0;

  while (!isInitialized && currentRetry < maxRetries) {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('No internet connection');
      }

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Configure Firestore settings for better offline support
      FirebaseFirestore.instance.settings = Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // Verify connection with a simple operation
      await FirebaseFirestore.instance
          .collection('test')
          .doc('connection_test')
          .get()
          .timeout(const Duration(seconds: 5));

      print('Firebase initialized successfully');
      isInitialized = true;
    } catch (e) {
      currentRetry++;
      print('Firebase connection attempt $currentRetry failed: $e');

      if (currentRetry < maxRetries) {
        // Exponential backoff with jitter
        final backoffDuration = Duration(
          milliseconds: (pow(2, currentRetry) * 1000).toInt() +
              Random().nextInt(1000),
        );
        await Future.delayed(backoffDuration);

        // Reset Firestore instance
        try {
          await FirebaseFirestore.instance.terminate();
          await FirebaseFirestore.instance.clearPersistence();
        } catch (e) {
          print('Error resetting Firestore: $e');
        }
      } else {
        print('Failed to connect to Firebase after $maxRetries attempts');
      }
    }
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WanderGem',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(),
    );
  }
}
