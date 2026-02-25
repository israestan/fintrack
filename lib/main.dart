import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'view_models/splash_view_model.dart';
import 'view_models/accounts_view_model.dart';
import 'view_models/navigation_view_model.dart';
import 'view_models/categories_view_model.dart';
import 'view_models/movements_view_model.dart';
import 'view_models/text_scale_view_model.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TextScaleViewModel()),
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        ChangeNotifierProvider(create: (_) => AccountsViewModel()..loadAccounts()),
        ChangeNotifierProvider(create: (_) => CategoriesViewModel()..loadAll()),
        ChangeNotifierProvider(create: (_) => MovementsViewModel()),
        ChangeNotifierProvider(create: (_) => NavigationViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinTrack',
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        // Apply global text scale factor from TextScaleViewModel
        final scale = context.watch<TextScaleViewModel>().scale;
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}
