import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import '../widgets/gota_icons.dart';
import 'emergency_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

/// Main 4-tab navigation shell matching the Bottom Navigation Bar on Pages 1, 3, 4, and 5.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  void _selectTab(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gotaColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onNavigateToTab: _selectTab),
          const HistoryScreen(),
          const EmergencyScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(color: colors.border.withValues(alpha: 0.7)),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 70,
            child: Row(
              children: [
                _NavItem(
                  label: 'Início',
                  selected: _currentIndex == 0,
                  onTap: () => _selectTab(0),
                  iconBuilder: (color) => Icon(
                    Icons.home_outlined,
                    size: 24,
                    color: color,
                  ),
                ),
                _NavItem(
                  label: 'Histórico',
                  selected: _currentIndex == 1,
                  onTap: () => _selectTab(1),
                  iconBuilder: (color) => Icon(
                    Icons.history_rounded,
                    size: 24,
                    color: color,
                  ),
                ),
                _NavItem(
                  label: 'Emergência',
                  selected: _currentIndex == 2,
                  onTap: () => _selectTab(2),
                  iconBuilder: (color) => SirenIcon(
                    size: 24,
                    color: color,
                  ),
                ),
                _NavItem(
                  label: 'Perfil',
                  selected: _currentIndex == 3,
                  onTap: () => _selectTab(3),
                  iconBuilder: (color) => Icon(
                    Icons.person_outline_rounded,
                    size: 24,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.iconBuilder,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget Function(Color color) iconBuilder;

  @override
  Widget build(BuildContext context) {
    final colors = context.gotaColors;
    final activeColor = colors.primary;
    final inactiveColor = colors.textSecondary;
    final fgColor = selected ? activeColor : inactiveColor;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 54,
              height: 32,
              decoration: BoxDecoration(
                color: selected ? colors.roseSurface : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: iconBuilder(fgColor),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: fgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
