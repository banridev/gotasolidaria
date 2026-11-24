import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Donor avatar widget matching Pages 1, 5, and 10, with local style options persisted in Hive.
class DonorAvatar extends StatelessWidget {
  const DonorAvatar({
    super.key,
    required this.size,
    required this.initials,
    this.styleIndex = 0,
    this.showOuterRing = false,
    this.showCameraBadge = false,
    this.onTap,
  });

  final double size;
  final String initials;
  final int styleIndex;
  final bool showOuterRing;
  final bool showCameraBadge;
  final VoidCallback? onTap;

  static const List<String> styleLabels = [
    'Clássico',
    'Iniciais',
    'Gota Solidária',
    'Coração Doador',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.gotaColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    Color fgColor;
    Widget innerContent;

    switch (styleIndex % 4) {
      case 1:
        bgColor = colors.primary;
        fgColor = Colors.white;
        innerContent = Text(
          initials,
          style: TextStyle(
            color: fgColor,
            fontSize: size * 0.34,
            fontWeight: FontWeight.w700,
          ),
        );
        break;
      case 2:
        bgColor = isDark ? const Color(0xFF471C22) : const Color(0xFFFCD5D9);
        fgColor = colors.primary;
        innerContent = Icon(
          Icons.water_drop_outlined,
          size: size * 0.46,
          color: fgColor,
        );
        break;
      case 3:
        bgColor = colors.mintSurface;
        fgColor = colors.success;
        innerContent = Icon(
          Icons.volunteer_activism_outlined,
          size: size * 0.46,
          color: fgColor,
        );
        break;
      case 0:
      default:
        bgColor = colors.avatarRose;
        fgColor = colors.primaryDeep;
        innerContent = Icon(
          Icons.person_outline_rounded,
          size: size * 0.48,
          color: fgColor,
        );
        break;
    }

    Widget circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
      ),
      alignment: Alignment.center,
      child: innerContent,
    );

    if (showOuterRing) {
      circle = Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: circle,
      );
    }

    if (showCameraBadge) {
      circle = Stack(
        clipBehavior: Clip.none,
        children: [
          circle,
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: size * 0.34,
              height: size * 0.34,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: colors.surface, width: 2.2),
              ),
              child: Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
                size: size * 0.17,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap == null) return circle;

    return GestureDetector(
      onTap: onTap,
      child: circle,
    );
  }
}
