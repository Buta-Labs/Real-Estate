import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_mmc_app/router/app_router.dart';
import 'package:orre_mmc_app/theme/app_theme.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:orre_mmc_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Orre MMC',
      theme: AppTheme.darkTheme, // Using dark theme as default
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
