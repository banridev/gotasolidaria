import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Custom Portuguese Date Picker Dialog matching Page 6 of GotaSolidaria.pdf literally.
Future<DateTime?> showGotaDatePicker({
  required BuildContext context,
  required DateTime initialDate,
}) {
  return showDialog<DateTime>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.48),
    builder: (context) => _GotaDatePickerDialog(initialDate: initialDate),
  );
}

class _GotaDatePickerDialog extends StatefulWidget {
  const _GotaDatePickerDialog({required this.initialDate});

  final DateTime initialDate;

  @override
  State<_GotaDatePickerDialog> createState() => _GotaDatePickerDialogState();
}

class _GotaDatePickerDialogState extends State<_GotaDatePickerDialog> {
  static const List<String> _monthsFull = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  static const List<String> _monthsShort = [
    'jan.',
    'fev.',
    'mar.',
    'abr.',
    'mai.',
    'jun.',
    'jul.',
    'ago.',
    'set.',
    'out.',
    'nov.',
    'dez.',
  ];

  static const List<String> _weekdaysFull = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];

  // Monday-first column headers matching Page 6: S T Q Q S S D
  static const List<String> _weekdayInitials = [
    'S',
    'T',
    'Q',
    'Q',
    'S',
    'S',
    'D',
  ];

  late DateTime _selectedDate;
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  String _formatHeaderDate(DateTime date) {
    final weekday = _weekdaysFull[date.weekday - 1];
    final monthShort = _monthsShort[date.month - 1];
    return '$weekday, ${date.day} de $monthShort';
  }

  String _formatMonthTitle(DateTime month) {
    return '${_monthsFull[month.month - 1]} ${month.year}';
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
        1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gotaColors;
    final daysInMonth = DateUtils.getDaysInMonth(
      _displayedMonth.year,
      _displayedMonth.month,
    );
    // DateTime.weekday: Monday = 1 ... Sunday = 7 -> leading blanks = weekday - 1
    final leadingBlanks = _displayedMonth.weekday - 1;
    final totalCells = leadingBlanks + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    return Dialog(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecionar Data',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatHeaderDate(_selectedDate),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 18),
            // Month navigation row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    color: colors.textPrimary,
                    size: 26,
                  ),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Mês anterior',
                ),
                Text(
                  _formatMonthTitle(_displayedMonth),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: colors.textPrimary,
                    size: 26,
                  ),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Próximo mês',
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Weekday headers
            Row(
              children: _weekdayInitials
                  .map(
                    (label) => Expanded(
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            // Calendar day rows
            for (int row = 0; row < rowCount; row++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: List.generate(7, (col) {
                    final cellIndex = row * 7 + col;
                    final dayNumber = cellIndex - leadingBlanks + 1;
                    if (dayNumber < 1 || dayNumber > daysInMonth) {
                      return const Expanded(child: SizedBox(height: 38));
                    }

                    final cellDate = DateTime(
                      _displayedMonth.year,
                      _displayedMonth.month,
                      dayNumber,
                    );
                    final isSelected = cellDate.year == _selectedDate.year &&
                        cellDate.month == _selectedDate.month &&
                        cellDate.day == _selectedDate.day;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = cellDate;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          height: 38,
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 140),
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? colors.primary
                                    : Colors.transparent,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$dayNumber',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : colors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            const SizedBox(height: 20),
            // Cancelar / OK buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(_selectedDate),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
