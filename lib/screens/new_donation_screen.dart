import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../models/blood_center.dart';
import '../models/donation_record.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/blood_center_sheet.dart';
import '../widgets/custom_date_picker_dialog.dart';
import '../widgets/custom_keyboards.dart';

enum _ActiveCustomKeyboard { none, numeric, text }

/// Pages 2, 6, 7, 8, and 9 — `Nova Doação` with custom date picker, blood center sheet,
/// numeric keyboard overlay, and QWERTY text keyboard overlay.
class NewDonationScreen extends StatefulWidget {
  const NewDonationScreen({super.key, this.initialDate});

  final DateTime? initialDate;

  @override
  State<NewDonationScreen> createState() => _NewDonationScreenState();
}

class _NewDonationScreenState extends State<NewDonationScreen> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _hardwareKeyboardFocus = FocusNode();

  late DateTime _selectedDate;
  BloodCenter? _selectedCenter;
  String _selectedType = 'Sangue Total';
  String _volumeText = '450';
  String _notesText = '';

  _ActiveCustomKeyboard _activeKeyboard = _ActiveCustomKeyboard.none;
  bool _cursorVisible = true;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    // Matches prototype Page 2 & Page 6 default (`28/09/2026`).
    _selectedDate = widget.initialDate ?? DateTime(2026, 9, 28);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedCenter == null) {
      final state = AppStateScope.of(context);
      final centers = state.bloodCenters;
      final favoriteId = state.profile.favoriteBloodCenterId;
      _selectedCenter = centers.firstWhere(
        (c) => c.id == favoriteId,
        orElse: () => centers.first,
      );
    }
  }

  @override
  void dispose() {
    _cursorTimer?.cancel();
    _scrollController.dispose();
    _hardwareKeyboardFocus.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  void _openKeyboard(_ActiveCustomKeyboard type) {
    _cursorTimer?.cancel();
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 520), (_) {
      if (mounted) {
        setState(() => _cursorVisible = !_cursorVisible);
      }
    });
    setState(() {
      _activeKeyboard = type;
      _cursorVisible = true;
    });
    _hardwareKeyboardFocus.requestFocus();
    if (type == _ActiveCustomKeyboard.text) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _closeKeyboard() {
    _cursorTimer?.cancel();
    _cursorTimer = null;
    if (_activeKeyboard == _ActiveCustomKeyboard.numeric &&
        _volumeText.trim().isEmpty) {
      _volumeText = '450';
    }
    setState(() => _activeKeyboard = _ActiveCustomKeyboard.none);
  }

  void _handleNumericDigit(String digit) {
    setState(() {
      if (_volumeText.length < 4) {
        if (_volumeText == '0') {
          _volumeText = digit;
        } else {
          _volumeText += digit;
        }
      }
      _cursorVisible = true;
    });
  }

  void _handleNumericBackspace() {
    setState(() {
      if (_volumeText.isNotEmpty) {
        _volumeText = _volumeText.substring(0, _volumeText.length - 1);
      }
      _cursorVisible = true;
    });
  }

  void _handleTextInsert(String text) {
    setState(() {
      _notesText += text;
      _cursorVisible = true;
    });
  }

  void _handleTextBackspace() {
    setState(() {
      if (_notesText.isNotEmpty) {
        final chars = _notesText.characters;
        _notesText = chars.skipLast(1).toString();
      }
      _cursorVisible = true;
    });
  }

  void _handleHardwareKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (_activeKeyboard == _ActiveCustomKeyboard.none) return;

    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_activeKeyboard == _ActiveCustomKeyboard.numeric) {
        _handleNumericBackspace();
      } else {
        _handleTextBackspace();
      }
      return;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.escape) {
      _closeKeyboard();
      return;
    }

    final char = event.character;
    if (char == null || char.isEmpty) return;

    if (_activeKeyboard == _ActiveCustomKeyboard.numeric) {
      if (RegExp(r'^[0-9]$').hasMatch(char)) {
        _handleNumericDigit(char);
      }
    } else if (_activeKeyboard == _ActiveCustomKeyboard.text) {
      if (char.codeUnitAt(0) >= 32) {
        _handleTextInsert(char);
      }
    }
  }

  Future<void> _pickDate() async {
    _closeKeyboard();
    final picked = await showGotaDatePicker(
      context: context,
      initialDate: _selectedDate,
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickBloodCenter() async {
    _closeKeyboard();
    final state = AppStateScope.of(context);
    final chosen = await showBloodCenterSelectorSheet(
      context: context,
      centers: state.bloodCenters,
      selectedCenter: _selectedCenter ?? state.bloodCenters.first,
    );
    if (chosen != null && mounted) {
      setState(() => _selectedCenter = chosen);
    }
  }

  Future<void> _saveDonation() async {
    _closeKeyboard();
    final state = AppStateScope.of(context);
    final parsedVolume = int.tryParse(_volumeText.trim()) ?? 450;
    final volumeMl = parsedVolume > 0 ? parsedVolume : 450;
    final center = _selectedCenter ?? state.bloodCenters.first;

    await state.addDonation(
      date: _selectedDate,
      bloodCenter: center,
      donationType: _selectedType,
      volumeMl: volumeMl,
      notes: _notesText,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Doação de ${volumeMl}ml registrada em ${center.name}!',
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gotaColors;
    final center = _selectedCenter ?? BloodCenter.initialCenters().first;
    final isNumericActive = _activeKeyboard == _ActiveCustomKeyboard.numeric;
    final isTextActive = _activeKeyboard == _ActiveCustomKeyboard.text;
    final isStandardVolume = _volumeText.trim() == '450';

    return KeyboardListener(
      focusNode: _hardwareKeyboardFocus,
      onKeyEvent: _handleHardwareKeyEvent,
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header bar: ← Nova Doação
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_activeKeyboard != _ActiveCustomKeyboard.none) {
                          _closeKeyboard();
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: colors.textPrimary,
                        size: 26,
                      ),
                      tooltip: 'Voltar',
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Nova Doação',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable form body
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (_activeKeyboard != _ActiveCustomKeyboard.none) {
                      _closeKeyboard();
                    }
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conte como foi sua doação',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Leva menos de um minuto e mantém seu histórico atualizado.',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Data da Doação
                        Text(
                          'Data da Doação',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _FormSelectorBox(
                          onTap: _pickDate,
                          leading: Icon(
                            Icons.calendar_month_outlined,
                            color: colors.primary,
                            size: 22,
                          ),
                          value: _formatDate(_selectedDate),
                        ),
                        const SizedBox(height: 18),

                        // Hemocentro / Local
                        Text(
                          'Hemocentro / Local',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _FormSelectorBox(
                          onTap: _pickBloodCenter,
                          leading: Icon(
                            Icons.location_on_outlined,
                            color: colors.primary,
                            size: 22,
                          ),
                          value: center.name,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          center.cityState,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Tipo de doação
                        Text(
                          'Tipo de doação',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            for (int i = 0;
                                i < DonationRecord.donationTypes.length;
                                i++) ...[
                              if (i > 0) const SizedBox(width: 8),
                              Expanded(
                                child: _DonationTypeChip(
                                  label: DonationRecord.donationTypes[i],
                                  selected: _selectedType ==
                                      DonationRecord.donationTypes[i],
                                  onTap: () {
                                    _closeKeyboard();
                                    setState(() {
                                      _selectedType =
                                          DonationRecord.donationTypes[i];
                                    });
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Volume
                        Text(
                          'Volume',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () =>
                              _openKeyboard(_ActiveCustomKeyboard.numeric),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isNumericActive
                                    ? colors.primary
                                    : colors.border,
                                width: isNumericActive ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _volumeText,
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                if (isNumericActive)
                                  AnimatedOpacity(
                                    opacity: _cursorVisible ? 1.0 : 0.0,
                                    duration:
                                        const Duration(milliseconds: 100),
                                    child: Container(
                                      width: 2,
                                      height: 24,
                                      margin: const EdgeInsets.only(left: 1),
                                      color: colors.primary,
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Text(
                                  'ml',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: colors.textSecondary,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  isStandardVolume
                                      ? 'VOLUME PADRÃO'
                                      : 'VOLUME INFORMADO',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                    color: isStandardVolume
                                        ? colors.success
                                        : colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Observações ou sintomas pós-doação (opcional)
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Observações ou sintomas pós-doação ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                              ),
                              TextSpan(
                                text: '(opcional)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () =>
                              _openKeyboard(_ActiveCustomKeyboard.text),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: double.infinity,
                            constraints: const BoxConstraints(minHeight: 92),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isTextActive
                                    ? colors.primary
                                    : colors.border,
                                width: isTextActive ? 2 : 1,
                              ),
                            ),
                            child: _notesText.isEmpty && !isTextActive
                                ? Text(
                                    'Ex.: tontura leve, hematoma ou tudo bem...',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      color: colors.textMuted,
                                    ),
                                  )
                                : Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        _notesText,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: colors.textPrimary,
                                          height: 1.4,
                                        ),
                                      ),
                                      if (isTextActive)
                                        AnimatedOpacity(
                                          opacity: _cursorVisible ? 1.0 : 0.0,
                                          duration: const Duration(
                                            milliseconds: 100,
                                          ),
                                          child: Container(
                                            width: 2,
                                            height: 20,
                                            margin:
                                                const EdgeInsets.only(left: 1),
                                            color: colors.primary,
                                          ),
                                        ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom section: either Custom Keyboard (Page 8 / Page 9) or Save Button (Page 2)
              if (_activeKeyboard == _ActiveCustomKeyboard.numeric)
                NumericDonationKeyboard(
                  onDigit: _handleNumericDigit,
                  onBackspace: _handleNumericBackspace,
                  onDone: _closeKeyboard,
                )
              else if (_activeKeyboard == _ActiveCustomKeyboard.text)
                TextDonationKeyboard(
                  onText: _handleTextInsert,
                  onBackspace: _handleTextBackspace,
                  onDone: _closeKeyboard,
                )
              else
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _saveDonation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shadowColor:
                                  colors.primary.withValues(alpha: 0.32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_rounded, size: 22),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Salvar Registro',
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
                        const SizedBox(height: 10),
                        Text(
                          'Seus dados de saúde ficam protegidos.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormSelectorBox extends StatelessWidget {
  const _FormSelectorBox({
    required this.onTap,
    required this.leading,
    required this.value,
  });

  final VoidCallback onTap;
  final Widget leading;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.gotaColors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colors.textSecondary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonationTypeChip extends StatelessWidget {
  const _DonationTypeChip({
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
        duration: const Duration(milliseconds: 160),
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colors.roseSurface : colors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? colors.primary : colors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? colors.primary : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
