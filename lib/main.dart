import 'package:expenses_tracker/app.dart';
import 'package:expenses_tracker/services/notifications/notifications.dart';
import 'package:expenses_tracker/simple_bloc_observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.instance.initialize();
  Bloc.observer = SimpleBlocObserver();
  runApp(const MyApp());
}
