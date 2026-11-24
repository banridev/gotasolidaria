import 'package:material_ui/material_ui.dart';

import 'screens/main_shell_screen.dart';
import 'services/app_state.dart';
import 'services/hive_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hiveService = HiveService();
  await hiveService.init();
  final appState = AppState(hiveService);

  runApp(GotaSolidariaApp(appState: appState));
}

class GotaSolidariaApp extends StatelessWidget {
  const GotaSolidariaApp({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: appState,
      child: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          return MaterialApp(
            title: 'GotaSolidária',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appState.themeMode,
            home: const MainShellScreen(),
          );
        },
      ),
    );
  }
}
