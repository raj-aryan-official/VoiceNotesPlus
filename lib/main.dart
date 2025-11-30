import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/splash/ui/splash_screen.dart';
import 'features/home/controller/home_controller.dart';
import 'features/notes/controller/notes_controller.dart';
import 'features/recording/controller/recording_controller.dart';
import 'features/notes/service/notes_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize Notes Service
  await NotesService.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotesController()),
        ChangeNotifierProvider(create: (_) => RecordingController()),
        ChangeNotifierProvider(create: (_) => HomeController()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const SplashScreen(),
      ),
    );
  }
}
