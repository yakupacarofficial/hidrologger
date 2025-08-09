import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelectionWidget extends StatefulWidget {
  final String selectedRange;
  final DateTime startDate;
  final DateTime endDate;
  final Function(String, DateTime?, DateTime?) onDateRangeChanged;

  const DateSelectionWidget({
    super.key,
    required this.selectedRange,
    required this.startDate,
    required this.endDate,
    required this.onDateRangeChanged,
  });

  @override
  State<DateSelectionWidget> createState() => _DateSelectionWidgetState();
}

class _DateSelectionWidgetState extends State<DateSelectionWidget> {
  late String _selectedRange;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _selectedRange = widget.selectedRange;
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  @override
  void didUpdateWidget(DateSelectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedRange != widget.selectedRange ||
        oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate) {
      setState(() {
        _selectedRange = widget.selectedRange;
        _startDate = widget.startDate;
        _endDate = widget.endDate;
      });
    }
  }

  void _onRangeSelected(String range) {
    final now = DateTime.now();
    DateTime? start;
    DateTime? end;

    switch (range) {
      case 'Bugün':
        start = DateTime(now.year, now.month, now.day);
        end = now;
        break;
      case 'Son 24 Saat':
        start = now.subtract(const Duration(days: 1));
        end = now;
        break;
      case 'Son 7 Gün':
        start = now.subtract(const Duration(days: 7));
        end = now;
        break;
      case 'Son 1 Ay':
        start = DateTime(now.year, now.month - 1, now.day);
        end = now;
        break;
      case 'Custom':
        _showCustomDateRangePicker();
        return;
    }

    setState(() {
      _selectedRange = range;
      if (start != null) _startDate = start;
      if (end != null) _endDate = end;
    });

    widget.onDateRangeChanged(range, start, end);
  }

  Future<void> _showCustomDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedRange = 'Custom';
        _startDate = picked.start;
        _endDate = picked.end;
      });

      widget.onDateRangeChanged('Custom', picked.start, picked.end);
    }
  }

  String _formatDateRange() {
    final dateFormat = DateFormat('dd.MM.yyyy');
    return '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tarih Aralığı Seçin',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          // Önceden tanımlı aralıklar
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Bugün',
              'Son 24 Saat',
              'Son 7 Gün',
              'Son 1 Ay',
              'Custom',
            ].map((range) => ChoiceChip(
              label: Text(range),
              selected: _selectedRange == range,
              onSelected: (selected) {
                if (selected) {
                  _onRangeSelected(range);
                }
              },
              selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              labelStyle: TextStyle(
                color: _selectedRange == range
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: _selectedRange == range ? FontWeight.w600 : FontWeight.normal,
              ),
            )).toList(),
          ),
          
          const SizedBox(height: 12),
          
          // Seçilen tarih aralığı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDateRange(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
