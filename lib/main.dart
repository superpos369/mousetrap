import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'config/router.dart';
import 'config/theme.dart';
import 'features/trap/trap_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Hide status bar for full-immersion
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Init AdMob
  await MobileAds.instance.initialize();

  runApp(const MousetrapApp());
}

class MousetrapApp extends StatelessWidget {
  const MousetrapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TrapProvider(),
      child: MaterialApp(
        title: 'Mousetrap',
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        onGenerateRoute: generateRoute,
        initialRoute: '/',
      ),
    );
  }
}
