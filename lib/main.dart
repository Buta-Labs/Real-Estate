import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_mmc_app/router/app_router.dart';
import 'package:orre_mmc_app/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:orre_mmc_app/firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:orre_mmc_app/core/config/app_config.dart';
import 'package:reown_appkit/reown_appkit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode
        ? AndroidProvider.debug
        : AndroidProvider.playIntegrity,
    appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
    webProvider: ReCaptchaEnterpriseProvider(AppConfig.recaptchaSiteKey),
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return ReownAppKitModalTheme(
      isDarkMode: true,
      child: MaterialApp.router(
        title: 'Orre',
        theme: AppTheme.darkTheme, // Using dark theme as default
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}
