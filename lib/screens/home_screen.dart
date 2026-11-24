import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/donor_avatar.dart';
import '../widgets/gota_icons.dart';
import 'new_donation_screen.dart';

/// Page 1 — Tela `Início` matching GotaSolidaria.pdf literally.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onNavigateToTab,
  });

  final ValueChanged<int> onNavigateToTab;

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final colors = context.gotaColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = state.profile;
    final latest = state.latestDonation;
    final daysRemaining = state.daysRemaining;
    final isEligible = state.isEligibleToDonate;
    final nextDate = state.nextEligibleDate;

    final String statusBadgeText;
    final Color statusBadgeBg;
    final Color statusBadgeFg;
    final IconData statusBadgeIcon;
    final String mainHeadline;
    final String mainSubtitle;

    if (!profile.isWeightEligible) {
      statusBadgeText = 'Peso abaixo do mínimo (50 kg)';
      statusBadgeBg = colors.warningSurface;
      statusBadgeFg = colors.warningTitle;
      statusBadgeIcon = Icons.info_outline_rounded;
      mainHeadline = 'Atualize seu peso para doar.';
      mainSubtitle = 'O peso mínimo para doação de sangue total é 50 kg.';
    } else if (daysRemaining == 0) {
      statusBadgeText = 'Você está apto para doar!';
      statusBadgeBg = colors.mintSurface;
      statusBadgeFg = colors.success;
      statusBadgeIcon = Icons.check_circle_outline_rounded;
      mainHeadline = 'Seu gesto pode salvar\naté 4 vidas.';
      mainSubtitle = 'Você já cumpriu o intervalo\nrecomendado.';
    } else {
      statusBadgeText = 'Aguardando intervalo';
      statusBadgeBg = colors.warningSurface;
      statusBadgeFg = colors.warningTitle;
      statusBadgeIcon = Icons.schedule_rounded;
      mainHeadline =
          'Faltam $daysRemaining ${daysRemaining == 1 ? 'dia' : 'dias'} para doar.';
      mainSubtitle = nextDate != null
          ? 'Próxima doação liberada em ${_formatDate(nextDate)}.'
          : 'Aguarde o intervalo recomendado.';
    }

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: Olá, Doador + Tipo badge + Profile avatar
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, Doador',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                          letterSpacing: -0.5,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: colors.roseSurface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BloodDropIcon(
                              size: 14,
                              color: colors.primaryDeep,
                              strokeWidth: 1.8,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Tipo: ${profile.bloodType}',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: colors.primaryDeep,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                DonorAvatar(
                  size: 46,
                  initials: profile.initials,
                  styleIndex: state.preferences.avatarStyleIndex,
                  showOuterRing: true,
                  onTap: () => onNavigateToTab(3),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Main eligibility card with circular counter ring
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(24),
                border: isDark ? Border.all(color: colors.border) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _EligibilityRing(
                    days: daysRemaining,
                    progress: state.eligibilityProgress,
                    isEligible: isEligible,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusBadgeBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                statusBadgeIcon,
                                size: 15,
                                color: statusBadgeFg,
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  statusBadgeText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: statusBadgeFg,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          mainHeadline,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                            height: 1.22,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          mainSubtitle,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: colors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ÚLTIMA DOAÇÃO card
            Material(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: () => onNavigateToTab(1),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.roseSurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: CalendarHeartIcon(
                          size: 22,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ÚLTIMA DOAÇÃO',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: colors.textSecondary,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              latest != null
                                  ? '${latest.formattedDate} no ${latest.displayShortName}'
                                  : 'Nenhuma doação registrada ainda',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Primary CTA: + Registrar Nova Doação
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const NewDonationScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shadowColor: colors.primary.withValues(alpha: 0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, size: 24, color: Colors.white),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Registrar Nova Doação',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Critical stock alert card
            Material(
              color: colors.warningSurface,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => onNavigateToTab(2),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.warningBorder,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.warningIconBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: colors.warningTitle,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estoque em nível crítico',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: colors.warningTitle,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'O- e A- precisam de doações urgentes.',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: isDark
                                    ? colors.textPrimary
                                    : const Color(0xFF4E3415),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: colors.warningTitle,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Hydration tip row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Hidrate-se bem e leve um documento com foto.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EligibilityRing extends StatelessWidget {
  const _EligibilityRing({
    required this.days,
    required this.progress,
    required this.isEligible,
  });

  final int days;
  final double progress;
  final bool isEligible;

  @override
  Widget build(BuildContext context) {
    final colors = context.gotaColors;
    return SizedBox(
      width: 112,
      height: 112,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress,
          ringColor: colors.primary,
          trackColor: colors.avatarRose,
          fillColor: colors.roseSurface,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$days',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                days == 1 ? 'dia' : 'dias',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.ringColor,
    required this.trackColor,
    required this.fillColor,
  });

  final double progress;
  final Color ringColor;
  final Color trackColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 8.5;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Inner soft pink fill
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - strokeWidth / 2 + 1, fillPaint);

    // Track circle
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final arcPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final clamped = progress.clamp(0.0, 1.0);
    if (clamped >= 0.999) {
      canvas.drawCircle(center, radius, arcPaint);
    } else if (clamped > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * clamped,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.ringColor != ringColor ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.fillColor != fillColor;
}
