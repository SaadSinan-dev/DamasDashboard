import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../domain/entities/report_query.dart';
import 'report_presentation.dart';

/// Search field, status filter chips and sort menu.
///
/// Stateful only to own the [TextEditingController]; the query itself lives in
/// the cubit, and this widget just reports changes upward.
class ReportsToolbar extends StatefulWidget {
  const ReportsToolbar({
    super.key,
    required this.query,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onSortChanged,
  });

  final ReportQuery query;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ReportStatusFilter> onFilterChanged;
  final ValueChanged<ReportSort> onSortChanged;

  @override
  State<ReportsToolbar> createState() => _ReportsToolbarState();
}

class _ReportsToolbarState extends State<ReportsToolbar> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.query.searchTerm);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: _controller,
          onChanged: widget.onSearchChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: context.l10n.reportsSearchHint,
            prefixIcon: const Icon(Icons.search_rounded),
            // Rebuilt from the controller so the clear button appears and
            // disappears with the text without rebuilding the whole page.
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (BuildContext context, TextEditingValue value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  onPressed: _clear,
                  icon: const Icon(Icons.close_rounded),
                  tooltip: context.l10n.actionClearSearch,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    for (final ReportStatusFilter filter
                        in ReportStatusFilter.values)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          end: AppSpacing.sm,
                        ),
                        child: FilterChip(
                          label: Text(filter.label(context.l10n)),
                          selected: widget.query.status == filter,
                          onSelected: (_) => widget.onFilterChanged(filter),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            PopupMenuButton<ReportSort>(
              icon: const Icon(Icons.sort_rounded),
              tooltip: context.l10n.reportSortLabel,
              initialValue: widget.query.sort,
              onSelected: widget.onSortChanged,
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<ReportSort>>[
                for (final ReportSort sort in ReportSort.values)
                  PopupMenuItem<ReportSort>(
                    value: sort,
                    child: Text(sort.label(context.l10n)),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
