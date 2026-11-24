import 'package:material_ui/material_ui.dart';

import '../models/donation_record.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import 'new_donation_screen.dart';

/// Page 3 — `Histórico de Doações` matching GotaSolidaria.pdf literally.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int? _selectedYear; // null == 'Todos'
  bool _showOlderYearsInTodos = false;

  void _openAddDonation({DateTime? initialDate}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NewDonationScreen(initialDate: initialDate),
      ),
    );
  }

  void _showDonationDetails(BuildContext context, DonationRecord record) {
    final colors = context.gotaColors;
    final state = AppStateScope.of(context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
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
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        record.bloodCenterName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.mintSurface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        record.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Data',
                  value: record.formattedDate,
                ),
                _DetailRow(
                  icon: Icons.water_drop_outlined,
                  label: 'Tipo e Volume',
                  value: record.typeAndVolume,
                ),
                _DetailRow(
                  icon: Icons.location_on_outlined,
                  label: 'Cidade',
                  value: record.cityState,
                ),
                if (record.notes.isNotEmpty)
                  _DetailRow(
                    icon: Icons.notes_rounded,
                    label: 'Observações',
                    value: record.notes,
                  ),
                if (record.verifiedByCenter)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          size: 18,
                          color: colors.success,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Registro verificado pelo hemocentro',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: colors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.of(sheetContext).pop();
                          await state.deleteDonation(record.id);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Registro removido do histórico.'),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: colors.primary,
                          size: 18,
                        ),
                        label: Text(
                          'Remover',
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Fechar',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final colors = context.gotaColors;
    final years = state.availableYears;
    final filtered = state.donationsForYear(_selectedYear);

    // Group donations by year descending
    final Map<int, List<DonationRecord>> grouped = {};
    for (final donation in filtered) {
      grouped.putIfAbsent(donation.date.year, () => []).add(donation);
    }
    final sortedGroupYears = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    final primaryYear =
        sortedGroupYears.isNotEmpty ? sortedGroupYears.first : null;
    final olderYears = sortedGroupYears.length > 1
        ? sortedGroupYears.sublist(1)
        : const <int>[];

    final totalCount = state.totalDonations;
    final impactMessage = totalCount == 0
        ? 'Registre sua primeira doação e comece a salvar vidas!'
        : 'Você já completou $totalCount ${totalCount == 1 ? 'doação' : 'doações'}. Que impacto lindo!';

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: Histórico de Doações + calendar action button
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Histórico de Doações',
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
                    onTap: () => _openAddDonation(),
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.calendar_today_outlined,
                        size: 20,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Red Hero Impact Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFC62828), Color(0xFFB71C1C)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volunteer_activism_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'Total de doações',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  color: Colors.white.withValues(alpha: 0.92),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$totalCount',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Vidas impactadas',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  color: Colors.white.withValues(alpha: 0.92),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'até ${state.livesImpacted} vidas',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
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

            // Filter Chips: Todos, 2026, 2025 (+ dynamic extra years)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterPill(
                    label: 'Todos',
                    selected: _selectedYear == null,
                    onTap: () => setState(() => _selectedYear = null),
                  ),
                  for (final year in years) ...[
                    const SizedBox(width: 10),
                    _FilterPill(
                      label: '$year',
                      selected: _selectedYear == year,
                      onTap: () => setState(() => _selectedYear = year),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Donation records grouped by year
            if (filtered.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 36,
                      color: colors.textMuted,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _selectedYear == null
                          ? 'Nenhuma doação registrada ainda.'
                          : 'Nenhum registro encontrado em $_selectedYear.',
                      style: TextStyle(
                        fontSize: 14.5,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // Always show primary / selected year group expanded first (matches Page 3: `2026` · `2 registros`)
              if (primaryYear != null)
                _YearGroupSection(
                  year: primaryYear,
                  records: grouped[primaryYear]!,
                  onTapRecord: (r) => _showDonationDetails(context, r),
                ),

              // Green Impact Banner (exact Page 3 placement right below primary records)
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: colors.mintSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.workspace_premium_outlined,
                      size: 20,
                      color: colors.success,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        impactMessage,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: colors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Left-aligned `+ Adicionar anterior` button matching Page 3
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _openAddDonation(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: colors.primary.withValues(alpha: 0.35),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 22),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Adicionar anterior',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Older years in 'Todos' view (expandable so Page 3 initial fold is identical AND all 5 Hive records remain accessible)
              if (_selectedYear == null && olderYears.isNotEmpty) ...[
                const SizedBox(height: 20),
                for (final year in olderYears) ...[
                  InkWell(
                    onTap: () => setState(
                      () => _showOlderYearsInTodos = !_showOlderYearsInTodos,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Text(
                            '$year',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: colors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${grouped[year]!.length} ${grouped[year]!.length == 1 ? 'registro' : 'registros'}',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _showOlderYearsInTodos
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: colors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showOlderYearsInTodos) ...[
                    const SizedBox(height: 8),
                    for (final record in grouped[year]!) ...[
                      _DonationCard(
                        record: record,
                        onTap: () => _showDonationDetails(context, record),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ],
              ],
            ],

            if (filtered.isEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _openAddDonation(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: colors.primary.withValues(alpha: 0.35),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 22),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Adicionar anterior',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _YearGroupSection extends StatelessWidget {
  const _YearGroupSection({
    required this.year,
    required this.records,
    required this.onTapRecord,
  });

  final int year;
  final List<DonationRecord> records;
  final ValueChanged<DonationRecord> onTapRecord;

  @override
  Widget build(BuildContext context) {
    final colors = context.gotaColors;
    final countLabel =
        '${records.length} ${records.length == 1 ? 'registro' : 'registros'}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$year',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.textSecondary,
              ),
            ),
            Text(
              countLabel,
              style: TextStyle(
                fontSize: 13.5,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final record in records) ...[
          _DonationCard(
            record: record,
            onTap: () => onTapRecord(record),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _DonationCard extends StatelessWidget {
  const _DonationCard({
    required this.record,
    required this.onTap,
  });

  final DonationRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.gotaColors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pink Date Tile
              Container(
                width: 60,
                height: 62,
                decoration: BoxDecoration(
                  color: colors.roseSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      record.dayTwoDigits,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      record.monthYearFormatted,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colors.primaryDeep,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            record.bloodCenterName,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.mintSurface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            record.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      record.typeAndVolume,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: colors.textSecondary,
                      ),
                    ),
                    if (record.verifiedByCenter) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Registro verificado pelo hemocentro',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                    if (record.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        record.notes,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontStyle: FontStyle.italic,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? colors.primary : colors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : colors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.gotaColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colors.textSecondary),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
