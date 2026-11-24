import 'package:material_ui/material_ui.dart';

import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/donor_avatar.dart';
import '../widgets/gota_icons.dart';
import 'edit_profile_screen.dart';

/// Page 5 — `Meu Perfil` matching GotaSolidaria.pdf literally.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _openEditProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const EditProfileScreen(),
      ),
    );
  }

  void _showInfoSheet(
    BuildContext context, {
    required String title,
    required List<({String heading, String body})> sections,
  }) {
    final colors = context.gotaColors;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.62,
          minChildSize: 0.4,
          maxChildSize: 0.88,
          expand: false,
          builder: (_, controller) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: ListView.separated(
                        controller: controller,
                        itemCount: sections.length,
                        separatorBuilder: (_, _) => Divider(
                          height: 22,
                          color: colors.divider,
                        ),
                        itemBuilder: (_, index) {
                          final item = sections[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.heading,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                item.body,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  height: 1.45,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Entendi',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    final colors = context.gotaColors;
    final state = AppStateScope.of(context);

    final choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Sair da conta',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          content: Text(
            'Na v1 local do GotaSolidária todos os dados ficam salvos apenas no seu aparelho (Hive). Deseja restaurar os dados iniciais do protótipo ou limpar seus dados locais?',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: colors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop('restore'),
              child: Text(
                'Restaurar protótipo',
                style: TextStyle(
                  color: colors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop('clear'),
              child: Text(
                'Limpar dados',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (choice == 'restore') {
      await state.resetToPrototypeDefaults();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados iniciais do protótipo restaurados no Hive.'),
        ),
      );
    } else if (choice == 'clear') {
      await state.clearAllUserData();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sessão local encerrada e dados limpos no Hive.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final colors = context.gotaColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = state.profile;
    final prefs = state.preferences;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Meu Perfil + circular edit button
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Meu Perfil',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                Material(
                  color: colors.surface,
                  shape: CircleBorder(side: BorderSide(color: colors.border)),
                  child: InkWell(
                    onTap: () => _openEditProfile(context),
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Profile Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: isDark ? Border.all(color: colors.border) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  DonorAvatar(
                    size: 70,
                    initials: profile.initials,
                    styleIndex: prefs.avatarStyleIndex,
                    showCameraBadge: true,
                    onTap: () => _openEditProfile(context),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.fullName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Doador desde ${profile.donorSinceYear}',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'Tipo: ${profile.bloodType}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: colors.roseSurface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                state.donorTierSummary,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: colors.primaryDeep,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card 1: Dados do Doador
            _ProfileSectionCard(
              title: 'Dados do Doador',
              children: [
                _DonorInfoRow(
                  iconBg: colors.roseSurface,
                  icon: Icon(
                    Icons.access_time_rounded,
                    size: 20,
                    color: colors.primary,
                  ),
                  label: 'Intervalo entre doações',
                  value: profile.intervalSummary,
                ),
                Divider(height: 22, color: colors.divider),
                _DonorInfoRow(
                  iconBg: colors.roseSurface,
                  icon: Icon(
                    Icons.balance_outlined,
                    size: 20,
                    color: colors.primary,
                  ),
                  label: 'Peso informado',
                  value: profile.weightSummary,
                  trailing: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: profile.isWeightEligible
                          ? colors.mintSurface
                          : colors.warningSurface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      profile.isWeightEligible
                          ? Icons.check_rounded
                          : Icons.priority_high_rounded,
                      size: 16,
                      color: profile.isWeightEligible
                          ? colors.success
                          : colors.warningTitle,
                    ),
                  ),
                ),
                Divider(height: 22, color: colors.divider),
                _DonorInfoRow(
                  iconBg: colors.roseSurface,
                  icon: Icon(
                    Icons.location_on_outlined,
                    size: 20,
                    color: colors.primary,
                  ),
                  label: 'Hemocentro favorito',
                  value: profile.favoriteBloodCenterName,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Card 2: Preferências e Aparência
            _ProfileSectionCard(
              title: 'Preferências e Aparência',
              children: [
                _PreferenceToggleRow(
                  iconBg: colors.roseSurface,
                  icon: Icon(
                    Icons.dark_mode_outlined,
                    size: 20,
                    color: colors.primary,
                  ),
                  label: 'Modo Escuro',
                  value: prefs.darkMode,
                  onChanged: state.setDarkMode,
                ),
                Divider(height: 22, color: colors.divider),
                _PreferenceToggleRow(
                  iconBg: colors.mintSurface,
                  icon: Icon(
                    Icons.notifications_active_outlined,
                    size: 20,
                    color: colors.success,
                  ),
                  label: 'Alertas de Estoque Crítico',
                  value: prefs.criticalStockAlerts,
                  onChanged: state.setCriticalStockAlerts,
                ),
                Divider(height: 22, color: colors.divider),
                _PreferenceToggleRow(
                  iconBg: colors.mintSurface,
                  icon: CalendarHeartIcon(
                    size: 20,
                    color: colors.success,
                  ),
                  label: 'Lembrete para Doar',
                  value: prefs.donationReminder,
                  onChanged: state.setDonationReminder,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Card 3: Ajuda & Sobre
            _ProfileSectionCard(
              title: 'Ajuda & Sobre',
              children: [
                _HelpNavigationRow(
                  icon: Icons.info_outline_rounded,
                  label: 'Requisitos e impedimentos para doar',
                  onTap: () => _showInfoSheet(
                    context,
                    title: 'Requisitos e impedimentos para doar',
                    sections: const [
                      (
                        heading: 'Requisitos básicos',
                        body:
                            'Ter entre 16 e 69 anos (menores de 18 com autorização), pesar no mínimo 50 kg, estar em boas condições de saúde, descansar bem na noite anterior e levar documento oficial com foto.',
                      ),
                      (
                        heading: 'Intervalo recomendado',
                        body:
                            'Homens podem doar a cada 60 dias (máximo de 4 doações em 12 meses). Mulheres podem doar a cada 90 dias (máximo de 3 doações em 12 meses).',
                      ),
                      (
                        heading: 'Impedimentos temporários comuns',
                        body:
                            'Gripe ou febre (aguardar 7 dias após melhora), tatuagem ou piercing recente (6 a 12 meses conforme normas do hemocentro), ingestão de álcool nas últimas 12 horas e cirurgias recentes.',
                      ),
                    ],
                  ),
                ),
                Divider(height: 20, color: colors.divider),
                _HelpNavigationRow(
                  icon: Icons.help_outline_rounded,
                  label: 'Dúvidas Frequentes (FAQ)',
                  onTap: () => _showInfoSheet(
                    context,
                    title: 'Dúvidas Frequentes (FAQ)',
                    sections: const [
                      (
                        heading: 'Quanto tempo leva uma doação?',
                        body:
                            'Todo o processo, incluindo cadastro, triagem clínica e coleta, dura cerca de 40 a 60 minutos. A coleta em si leva em torno de 10 minutos.',
                      ),
                      (
                        heading: 'Preciso estar em jejum para doar?',
                        body:
                            'Não! Alimente-se normalmente evitando comidas gordurosas nas 3 horas que antecedem a doação e hidrate-se bem.',
                      ),
                      (
                        heading: 'Quantas vidas uma doação pode salvar?',
                        body:
                            'Uma única bolsa de sangue total (450 ml) pode ser fracionada em hemocomponentes e ajudar até 4 pessoas.',
                      ),
                    ],
                  ),
                ),
                Divider(height: 20, color: colors.divider),
                _HelpNavigationRow(
                  icon: Icons.verified_user_outlined,
                  label: 'Termos e Privacidade',
                  onTap: () => _showInfoSheet(
                    context,
                    title: 'Termos e Privacidade',
                    sections: const [
                      (
                        heading: 'Armazenamento 100% local',
                        body:
                            'Nesta versão do GotaSolidária, seu perfil, histórico de doações, hemocentros e preferências são armazenados exclusivamente no seu dispositivo utilizando Hive.',
                      ),
                      (
                        heading: 'Controle total dos seus dados',
                        body:
                            'Nenhum dado pessoal ou de saúde é enviado para servidores externos. Você pode editar ou excluir seus dados a qualquer momento em Editar Perfil.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Sair da conta
            Center(
              child: TextButton.icon(
                onPressed: () => _handleSignOut(context),
                style: TextButton.styleFrom(
                  foregroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text(
                  'Sair da conta',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.gotaColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _DonorInfoRow extends StatelessWidget {
  const _DonorInfoRow({
    required this.iconBg,
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final Color iconBg;
  final Widget icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.gotaColors;
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: icon,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}

class _PreferenceToggleRow extends StatelessWidget {
  const _PreferenceToggleRow({
    required this.iconBg,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final Color iconBg;
  final Widget icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.gotaColors;
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: icon,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
        ),
        GotaSwitch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _HelpNavigationRow extends StatelessWidget {
  const _HelpNavigationRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.gotaColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.roseSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 19, color: colors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
