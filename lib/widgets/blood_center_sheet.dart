import 'package:material_ui/material_ui.dart';

import '../models/blood_center.dart';
import '../theme/app_theme.dart';

/// Modal bottom sheet `Selecione o Hemocentro` matching Page 7 literally.
Future<BloodCenter?> showBloodCenterSelectorSheet({
  required BuildContext context,
  required List<BloodCenter> centers,
  required BloodCenter selectedCenter,
}) {
  return showModalBottomSheet<BloodCenter>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (context) => _BloodCenterSelectorSheet(
      centers: centers,
      initialSelected: selectedCenter,
    ),
  );
}

class _BloodCenterSelectorSheet extends StatefulWidget {
  const _BloodCenterSelectorSheet({
    required this.centers,
    required this.initialSelected,
  });

  final List<BloodCenter> centers;
  final BloodCenter initialSelected;

  @override
  State<_BloodCenterSelectorSheet> createState() =>
      _BloodCenterSelectorSheetState();
}

class _BloodCenterSelectorSheetState extends State<_BloodCenterSelectorSheet> {
  final TextEditingController _searchController = TextEditingController();
  late BloodCenter _selected;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gotaColors;
    final filtered =
        widget.centers.where((c) => c.matchesQuery(_query)).toList();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Selecione o Hemocentro',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 14),
              // Search input
              Container(
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.border),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _query = val),
                  style: TextStyle(fontSize: 15, color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome ou bairro...',
                    hintStyle: TextStyle(
                      fontSize: 15,
                      color: colors.textMuted,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: colors.textSecondary,
                      size: 22,
                    ),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: Icon(
                              Icons.close_rounded,
                              color: colors.textMuted,
                              size: 20,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Blood centers list
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: Text(
                            'Nenhum hemocentro encontrado para "$_query".',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => Divider(
                          height: 1,
                          thickness: 1,
                          color: colors.divider,
                        ),
                        itemBuilder: (context, index) {
                          final center = filtered[index];
                          final isSelected = center.id == _selected.id;

                          return InkWell(
                            onTap: () => setState(() => _selected = center),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Row(
                                children: [
                                  // Circular check indicator matching Page 7
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? colors.primary
                                            : colors.border,
                                        width: isSelected ? 2.4 : 1.6,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          center.name,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: colors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          center.address,
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            color: colors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Icon(
                                        Icons.check_rounded,
                                        color: colors.primary,
                                        size: 22,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 18),
              // Confirmar Local button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(_selected),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Confirmar Local',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
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
