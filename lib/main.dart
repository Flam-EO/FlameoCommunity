import 'package:flameo/app.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meta_seo/meta_seo.dart';
import 'firebase_options.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ConfigProvider configProvider = ConfigProvider(configFileName: '__config__.json');
  await configProvider.loadConfig();
  WidgetsFlutterBinding.ensureInitialized();
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    debugPrint('[${record.time}] [${record.level.name}]: ${record.loggerName} - ${record.message}');
  });
  usePathUrlStrategy();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (configProvider.seoEnabled && kIsWeb) {
    MetaSEO().config();
  }
  runApp(MyApp(configProvider));
}