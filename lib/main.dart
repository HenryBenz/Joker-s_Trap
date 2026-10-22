import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/audio_service.dart';
import 'core/purchase_service.dart';
import 'core/save_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  final audio = AudioService();
  final purchases = PurchaseService();
  final controller = AppController(
    saveService: SaveService(),
    audio: audio,
    purchases: purchases,
  );
  runApp(JokersTrapApp(controller: controller));
  // The scene is not attached until runApp. Waiting here deadlocks on iOS
  // and leaves the launch screen up. Portrait is already locked in Info.plist.
  SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
