import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../models/blood_center.dart';
import '../models/donor_profile.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/blood_center_sheet.dart';
import '../widgets/donor_avatar.dart';

/// Page 10 — `Editar Perfil` matching GotaSolidaria.pdf literally.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  bool _initialized = false;
  late String _bloodType;
  late String _biologicalSex;
  late BloodCenter _preferredCenter;
  late int _avatarStyleIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final state = AppStateScope.of(context);
      final profile = state.profile;
      _nameController.text = profile.fullName;
      _emailController.text = profile.email;
      _weightController.text = '${profile.weightKg}';
      _bloodType = profile.bloodType;
      _biologicalSex = profile.biologicalSex;
      _avatarStyleIndex = state.preferences.avatarStyleIndex;
      _preferredCenter = state.bloodCenters.firstWhere(
        (c) => c.id == profile.favoriteBloodCenterId,
        orElse: () => state.bloodCenters.first,
      );
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final state = AppStateScope.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe seu nome completo.')),
      );
      return;
    }

    final parsedWeight = int.tryParse(_weightController.text.trim());
    if (parsedWeight == null || parsedWeight < 20 || parsedWeight > 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um peso válido em kg.')),
      );
      return;
    }

    final updated = state.profile.copyWith(
      fullName: name,
      email: _emailController.text.trim(),
      bloodType: _bloodType,
      biologicalSex: _biologicalSex,
      weightKg: parsedWeight,
      favoriteBloodCenterId: _preferredCenter.id,
      favoriteBloodCenterName: _preferredCenter.name,
    );

    await Future.wait([
      state.updateProfile(updated),
      if (_avatarStyleIndex != state.preferences.avatarStyleIndex)
        state.setAvatarStyleIndex(_avatarStyleIndex),
    ]);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alterações salvas com sucesso!')),
    );
    Navigator.of(context).pop();
  }

  Future<void> _openAvatarStylePicker() async {
    final colors = context.gotaColors;
    final currentInitials = _nameController.text.trim().isEmpty
        ? 'CS'
        : DonorProfile.initial()
            .copyWith(fullName: _nameController.text.trim())
            .initials;

    final chosen = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  'Trocar foto do perfil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(4, (index) {
                    final selected = index == _avatarStyleIndex;
                    return GestureDetector(
                      onTap: () => Navigator.of(sheetContext).pop(index),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected
                                    ? colors.primary
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: DonorAvatar(
                              size: 56,
                              initials: currentInitials,
                              styleIndex: index,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            DonorAvatar.styleLabels[index],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w500,
                              color: selected
                                  ? colors.primary
                                  : colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (chosen != null && mounted) {
      setState(() => _avatarStyleIndex = chosen);
    }
  }

  Future<void> _pickPreferredCenter() async {
    final state = AppStateScope.of(context);
    final chosen = await showBloodCenterSelectorSheet(
      context: context,
      centers: state.bloodCenters,
      selectedCenter: _preferredCenter,
    );
    if (chosen != null && mounted) {
      setState(() => _preferredCenter = chosen);
    }
  }

  Future<void> _showResetPasswordDialog() async {
    final colors = context.gotaColors;
    final email = _emailController.text.trim().isEmpty
        ? 'seu e-mail cadastrado'
        : _emailController.text.trim();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Redefinir Senha',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        content: Text(
          'Na v1 local do GotaSolidária não há login em nuvem. Caso configure uma conta futura, as instruções de redefinição serão enviadas para $email.',
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
              'Fechar',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDataDialog() async {
    final colors = context.gotaColors;
    final state = AppStateScope.of(context);

    final action = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Excluir meus dados',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        content: Text(
          'Você pode limpar todos os dados salvos no Hive ou restaurar os registros iniciais do protótipo GotaSolidária.',
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
            onPressed: () => Navigator.of(dialogContext).pop('delete'),
            child: Text(
              'Excluir tudo',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (action == 'restore') {
      await state.resetToPrototypeDefaults();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados iniciais do protótipo restaurados.'),
        ),
      );
      Navigator.of(context).pop();
    } else if (action == 'delete') {
      await state.clearAllUserData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos os seus dados locais foram excluídos do Hive.'),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gotaColors;
    final currentInitials = DonorProfile.initial()
        .copyWith(fullName: _nameController.text.trim())
        .initials;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top bar: ← Editar Perfil ... Salvar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 6),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: colors.textPrimary,
                      size: 26,
                    ),
                    tooltip: 'Voltar',
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Editar Perfil',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _saveChanges,
                    child: Text(
                      'Salvar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable form body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
                child: Column(
                  children: [
                    // Centered Avatar + Trocar foto
                    DonorAvatar(
                      size: 74,
                      initials: currentInitials,
                      styleIndex: _avatarStyleIndex,
                      showCameraBadge: true,
                      onTap: _openAvatarStylePicker,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _openAvatarStylePicker,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: Text(
                          'Trocar foto',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Card 1: Informações Pessoais
                    _EditCard(
                      title: 'Informações Pessoais',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _LabeledFieldBox(
                                  label: 'Nome Completo',
                                  controller: _nameController,
                                  keyboardType: TextInputType.name,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _LabeledFieldBox(
                                  label: 'E-mail',
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Tipo Sanguíneo',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // All 8 blood types on a single neat row matching Page 10
                          Row(
                            children: [
                              for (int i = 0;
                                  i < DonorProfile.bloodTypes.length;
                                  i++) ...[
                                if (i > 0) const SizedBox(width: 4),
                                Expanded(
                                  flex: DonorProfile.bloodTypes[i].length == 3
                                      ? 13
                                      : 10,
                                  child: _BloodTypePill(
                                    label: DonorProfile.bloodTypes[i],
                                    selected:
                                        _bloodType == DonorProfile.bloodTypes[i],
                                    onTap: () => setState(
                                      () => _bloodType =
                                          DonorProfile.bloodTypes[i],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 14),
                          Divider(height: 1, color: colors.divider),
                          const SizedBox(height: 12),
                          Text(
                            'Sexo Biológico (para cálculo de intervalo)',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _SexRadioOption(
                                  label: 'Masculino (60 dias / máx 4x ano)',
                                  selected: _biologicalSex == 'Masculino',
                                  onTap: () => setState(
                                    () => _biologicalSex = 'Masculino',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _SexRadioOption(
                                  label: 'Feminino (90 dias / máx 3x ano)',
                                  selected: _biologicalSex == 'Feminino',
                                  onTap: () => setState(
                                    () => _biologicalSex = 'Feminino',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Card 2: Dados de Aptidão
                    _EditCard(
                      title: 'Dados de Aptidão',
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _LabeledFieldBox(
                                  label: 'Peso atual (kg)',
                                  controller: _weightController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(3),
                                  ],
                                  suffixText: 'kg',
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Mínimo 50 kg para doação de sangue total',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: colors.textSecondary,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickPreferredCenter,
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  8,
                                  8,
                                  10,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: colors.border),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Hemocentro Preferido',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w500,
                                              color: colors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _preferredCenter.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w600,
                                              color: colors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 20,
                                      color: colors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Card 3: Ações da Conta
                    _EditCard(
                      title: 'Ações da Conta',
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 46,
                              child: OutlinedButton(
                                onPressed: _showResetPasswordDialog,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colors.primary,
                                  side: BorderSide(
                                    color: colors.primary,
                                    width: 1.2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                                child: const Text(
                                  'Redefinir Senha',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 46,
                              child: ElevatedButton.icon(
                                onPressed: _showDeleteDataDialog,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.roseSurface,
                                  foregroundColor: colors.primary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Excluir meus dados',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Fixed Button: Confirmar Alterações
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: colors.primary.withValues(alpha: 0.32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Confirmar Alterações',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

class _EditCard extends StatelessWidget {
  const _EditCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

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
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _LabeledFieldBox extends StatelessWidget {
  const _LabeledFieldBox({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.suffixText,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffixText;

  @override
  Widget build(BuildContext context) {
    final colors = context.gotaColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
              border: InputBorder.none,
              suffixText: suffixText,
              suffixStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BloodTypePill extends StatelessWidget {
  const _BloodTypePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.gotaColors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? colors.primary : colors.border,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : colors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _SexRadioOption extends StatelessWidget {
  const _SexRadioOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.gotaColors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? colors.primary : colors.textSecondary,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: selected
                ? Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
