part of '../../app/app.dart';

const _timelineCategories = <String, String>{
  'OPERACIONAL': 'Operacional',
  'RH': 'RH',
  'CONTRATO': 'Contrato',
  'EMPRESA': 'Empresa',
  'FINANCEIRO': 'Financeiro',
  'RELATORIO': 'Relatorio',
  'OCORRENCIA': 'Ocorrencia',
  'OUTRO': 'Outro',
};

const _timelineNatures = <String, String>{
  'NEUTRAL': 'Neutro',
  'POSITIVE': 'Positivo',
  'NEGATIVE': 'Negativo',
};

const _timelineLinkTypeLabels = <String, String>{
  'PROVIDER_COMPANY': 'Prestadora',
  'CLIENT_COMPANY': 'Cliente',
  'CONTRACT': 'Contrato',
  'CONTRACT_TEXT': 'Contrato informado',
  'PERSON': 'Funcionario',
  'GROUP': 'Grupo',
  'CITY': 'Cidade',
  'OTHER': 'Outro',
};

class _TimelineWorkspace extends StatefulWidget {
  const _TimelineWorkspace({required this.viewerProfile});

  final _ViewerAccessProfile viewerProfile;

  @override
  State<_TimelineWorkspace> createState() => _TimelineWorkspaceState();
}

class _TimelineWorkspaceState extends State<_TimelineWorkspace> {
  final _repository = _TimelineApiRepository();
  final _searchController = TextEditingController();
  late DateTime _month;
  DateTime? _selectedDate;
  DateTime? _rangeEnd;
  var _records = <_TimelineRecord>[];
  var _calendarEntries = <_TimelineCalendarEntry>[];
  var _nonBusinessDays = <_TimelineNonBusinessDay>[];
  var _category = '';
  var _entityType = '';
  bool _monthOnly = false;
  bool _rangeMode = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    unawaited(_load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedRecords = _records
        .where((record) => _recordMatchesSelection(record))
        .toList();
    final selectedCalendarEntries = _calendarEntries
        .where((entry) => _dateMatchesSelection(entry.occurrenceStartsAt))
        .toList();
    final selectedNonBusinessDays = _nonBusinessDays
        .where((item) => _dateMatchesSelection(item.date))
        .toList();
    final undatedRecords = _records
        .where((record) => record.eventDate == null)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Panel(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              const SizedBox(height: 16),
              _filters(context),
              if (_error != null) ...[
                const SizedBox(height: 12),
                _TimelineBanner(
                  icon: Icons.cloud_off_outlined,
                  text: _error!,
                  color: _roseColor,
                ),
              ],
              const SizedBox(height: 18),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: _TimelineCalendar(
                    month: _month,
                    selectedDate: _selectedDate,
                    rangeEnd: _rangeEnd,
                    records: _records,
                    calendarEntries: _calendarEntries,
                    nonBusinessDays: _nonBusinessDays,
                    onOpenDate: (date) => unawaited(_handleCalendarDate(date)),
                    onAddRecord: (date) =>
                        unawaited(_openRecordDialog(initialDate: date)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _recordsPanel(
          context,
          selectedRecords,
          undatedRecords,
          selectedCalendarEntries,
          selectedNonBusinessDays,
        ),
      ],
    );
  }

  Widget _header(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 760;
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Timeline', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              _monthLabel(_month),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _mutedColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        );
        final actions = Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            IconButton(
              tooltip: 'Mes anterior',
              onPressed: _loading
                  ? null
                  : () {
                      setState(() {
                        _month = DateTime(_month.year, _month.month - 1);
                        _selectedDate = null;
                        _rangeEnd = null;
                      });
                      unawaited(_load());
                    },
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            IconButton(
              tooltip: 'Proximo mes',
              onPressed: _loading
                  ? null
                  : () {
                      setState(() {
                        _month = DateTime(_month.year, _month.month + 1);
                        _selectedDate = null;
                        _rangeEnd = null;
                      });
                      unawaited(_load());
                    },
              icon: const Icon(Icons.chevron_right_rounded),
            ),
            IconButton(
              tooltip: 'Atualizar',
              onPressed: _loading ? null : () => unawaited(_load()),
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded),
            ),
            FilledButton.icon(
              onPressed: _loading ? null : _openRecordDialog,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Novo registro'),
            ),
          ],
        );

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, const SizedBox(height: 12), actions],
          );
        }
        return Row(
          children: [
            Expanded(child: title),
            actions,
          ],
        );
      },
    );
  }

  Widget _filters(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _ContextSearchField(
          controller: _searchController,
          hintText: 'buscar registros, empresas, contratos...',
          accent: _tealColor,
          maxWidth: 360,
          onSubmitted: (_) => unawaited(_load()),
          onClear: () {
            _searchController.clear();
            unawaited(_load());
          },
          onSearch: () => unawaited(_load()),
        ),
        _TimelineDropdownFilter(
          label: 'Categoria',
          value: _category,
          values: {'': 'Todas', ..._timelineCategories},
          onChanged: (value) {
            setState(() => _category = value ?? '');
            unawaited(_load());
          },
        ),
        _TimelineDropdownFilter(
          label: 'Vinculo',
          value: _entityType,
          values: {'': 'Todos', ..._timelineLinkTypeLabels},
          onChanged: (value) {
            setState(() => _entityType = value ?? '');
            unawaited(_load());
          },
        ),
        FilterChip(
          selected: _monthOnly,
          avatar: const Icon(Icons.calendar_view_month_outlined, size: 18),
          label: const Text('Sem data especifica'),
          onSelected: (value) {
            setState(() => _monthOnly = value);
            unawaited(_load());
          },
        ),
        FilterChip(
          selected: _rangeMode,
          avatar: const Icon(Icons.date_range_outlined, size: 18),
          label: const Text('Selecionar periodo'),
          onSelected: (value) {
            setState(() {
              _rangeMode = value;
              if (!value) {
                _rangeEnd = null;
              }
            });
          },
        ),
        if (_selectedDate != null)
          ActionChip(
            avatar: const Icon(Icons.close_rounded, size: 18),
            label: Text(_selectionLabel()),
            onPressed: () {
              setState(() {
                _selectedDate = null;
                _rangeEnd = null;
              });
            },
          ),
      ],
    );
  }

  Widget _recordsPanel(
    BuildContext context,
    List<_TimelineRecord> selectedRecords,
    List<_TimelineRecord> undatedRecords,
    List<_TimelineCalendarEntry> selectedCalendarEntries,
    List<_TimelineNonBusinessDay> selectedNonBusinessDays,
  ) {
    final visible = _selectedDate == null ? _records : selectedRecords;
    final visibleCalendarEntries = _selectedDate == null
        ? _calendarEntries
        : selectedCalendarEntries;
    final visibleNonBusinessDays = _selectedDate == null
        ? _nonBusinessDays
        : selectedNonBusinessDays;
    final totalItems =
        visible.length +
        visibleCalendarEntries.length +
        visibleNonBusinessDays.length;
    final title = _selectedDate == null
        ? 'Agenda de ${_monthLabel(_month)}'
        : 'Agenda de ${_selectionLabel()}';

    return _Panel(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              _Tag(
                label: '$totalItems itens',
                icon: Icons.format_list_bulleted_rounded,
                color: _deepTealColor,
                background: _deepTealColor.withValues(alpha: 0.09),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading && totalItems == 0)
            const LinearProgressIndicator(minHeight: 2)
          else if (totalItems == 0)
            const _TimelineBanner(
              icon: Icons.event_available_outlined,
              text:
                  'Nenhum evento, lembrete ou registro encontrado para o recorte atual.',
              color: _mutedColor,
            )
          else ...[
            if (visibleCalendarEntries.isNotEmpty) ...[
              _timelineSectionTitle(context, 'Eventos e lembretes'),
              const SizedBox(height: 8),
              for (final entry in visibleCalendarEntries) ...[
                _TimelineCalendarEntryTile(
                  entry: entry,
                  onOpen: () => _openCalendarEntryDetails(entry),
                ),
                const SizedBox(height: 10),
              ],
            ],
            if (visibleNonBusinessDays.isNotEmpty) ...[
              _timelineSectionTitle(context, 'Feriados e dias nao uteis'),
              const SizedBox(height: 8),
              for (final item in visibleNonBusinessDays) ...[
                _TimelineNonBusinessDayTile(item: item),
                const SizedBox(height: 10),
              ],
            ],
            if (visible.isNotEmpty) ...[
              _timelineSectionTitle(context, 'Registros da Timeline'),
              const SizedBox(height: 8),
              for (final record in visible) ...[
                _TimelineRecordTile(
                  record: record,
                  onOpen: () => _openRecordDetails(record),
                  onEdit: () => _openRecordDialog(record: record),
                  onRemove: () => _confirmRemove(record),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ],
          if (_selectedDate != null && undatedRecords.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Registros gerais do mes',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: _inkColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            for (final record in undatedRecords.take(6)) ...[
              _TimelineRecordTile(
                record: record,
                compact: true,
                onOpen: () => _openRecordDetails(record),
                onEdit: () => _openRecordDialog(record: record),
                onRemove: () => _confirmRemove(record),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _load() async {
    if (_loading) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final firstDay = DateTime(_month.year, _month.month);
      final lastDay = DateTime(_month.year, _month.month + 1, 0);
      final recordsRequest = _repository.listRecords(
        referenceMonth: _monthQuery(_month),
        search: _searchController.text,
        category: _category,
        entityType: _entityType,
        monthOnly: _monthOnly,
      );
      final calendarEntriesRequest = _repository.listCalendarEntries(
        from: _dateQuery(firstDay),
        to: _dateQuery(lastDay),
      );
      final nonBusinessDaysRequest = _repository.listNonBusinessDays(
        from: _dateQuery(firstDay),
        to: _dateQuery(lastDay),
      );
      final records = await recordsRequest;
      final calendarEntries = await calendarEntriesRequest;
      final nonBusinessDays = await nonBusinessDaysRequest;
      if (!mounted) {
        return;
      }
      setState(() {
        _records = records;
        _calendarEntries = calendarEntries;
        _nonBusinessDays = nonBusinessDays;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _records = const [];
        _calendarEntries = const [];
        _nonBusinessDays = const [];
        _error =
            'API indisponivel para Timeline (${error.code}). Nenhum dado mock foi carregado.';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openRecordDialog({
    _TimelineRecord? record,
    DateTime? initialDate,
  }) async {
    if (initialDate != null && mounted) {
      setState(() {
        _selectedDate = initialDate;
        _rangeEnd = null;
      });
    }
    final lookups = await _repository.loadLookups();
    if (!mounted) {
      return;
    }
    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _TimelineRecordDialog(
        month: _month,
        selectedDate: record?.eventDate ?? initialDate ?? _selectedDate,
        record: record,
        lookups: lookups,
      ),
    );
    if (body == null || !mounted) {
      return;
    }

    setState(() => _loading = true);
    try {
      if (record == null) {
        await _repository.createRecord(body);
      } else {
        await _repository.updateRecord(record.publicId, body);
      }
      if (mounted) {
        setState(() => _loading = false);
      }
      await _load();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            record == null ? 'Registro criado.' : 'Registro atualizado.',
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: _roseColor),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _handleCalendarDate(DateTime date) async {
    if (_rangeMode) {
      _selectRangeDate(date);
      return;
    }
    setState(() {
      _selectedDate = date;
      _rangeEnd = null;
    });
    await _openDayAgenda(date);
  }

  void _selectRangeDate(DateTime date) {
    setState(() {
      if (_selectedDate == null || _rangeEnd != null) {
        _selectedDate = date;
        _rangeEnd = null;
        return;
      }

      if (date.isBefore(_selectedDate!)) {
        _rangeEnd = _selectedDate;
        _selectedDate = date;
      } else {
        _rangeEnd = date;
      }
    });
  }

  Future<void> _openDayAgenda(DateTime date) async {
    final records = _recordsForDay(date);
    final entries = _calendarEntriesForDay(date);
    final nonBusinessDays = _nonBusinessDaysForDay(date);
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.15),
      builder: (dialogContext) => _TimelineDayAgendaDialog(
        date: date,
        records: records,
        calendarEntries: entries,
        nonBusinessDays: nonBusinessDays,
        onAddRecord: () {
          Navigator.of(dialogContext).pop();
          unawaited(_openRecordDialog(initialDate: date));
        },
        onOpenRecord: (record) {
          Navigator.of(dialogContext).pop();
          unawaited(_openRecordDetails(record));
        },
        onOpenCalendarEntry: (entry) {
          Navigator.of(dialogContext).pop();
          unawaited(_openCalendarEntryDetails(entry));
        },
      ),
    );
  }

  Future<void> _openRecordDetails(_TimelineRecord record) async {
    final action = await showDialog<String>(
      context: context,
      builder: (context) => _TimelineRecordDetailsDialog(record: record),
    );
    if (!mounted) {
      return;
    }
    if (action == 'edit') {
      await _openRecordDialog(record: record);
    } else if (action == 'remove') {
      await _confirmRemove(record);
    }
  }

  Future<void> _openCalendarEntryDetails(_TimelineCalendarEntry entry) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _TimelineCalendarEntryDetailsDialog(entry: entry),
    );
  }

  Future<void> _confirmRemove(_TimelineRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover registro'),
        content: Text(
          'O registro "${record.title}" sera removido da Timeline sem apagar historico fisico do banco.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await _repository.removeRecord(record.publicId);
      await _load();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: _roseColor),
      );
    }
  }

  List<_TimelineRecord> _recordsForDay(DateTime date) {
    return _records.where((record) {
      final eventDate = record.eventDate;
      return eventDate != null && _sameDate(eventDate, date);
    }).toList();
  }

  List<_TimelineCalendarEntry> _calendarEntriesForDay(DateTime date) {
    return _calendarEntries
        .where((entry) => _sameDate(entry.occurrenceStartsAt, date))
        .toList();
  }

  List<_TimelineNonBusinessDay> _nonBusinessDaysForDay(DateTime date) {
    return _nonBusinessDays.where((item) {
      if (_sameDate(item.date, date)) {
        return true;
      }
      return item.isRecurringYearly &&
          item.date.month == date.month &&
          item.date.day == date.day;
    }).toList();
  }

  bool _recordMatchesSelection(_TimelineRecord record) {
    if (_selectedDate == null) {
      return true;
    }
    return _dateMatchesSelection(record.eventDate);
  }

  bool _dateMatchesSelection(DateTime? date) {
    if (_selectedDate == null) {
      return true;
    }
    if (date == null) {
      return false;
    }
    return _isDateInRange(date, _selectedDate!, _rangeEnd ?? _selectedDate!);
  }

  String _selectionLabel() {
    if (_selectedDate == null) {
      return _monthLabel(_month);
    }
    if (_rangeEnd == null || _sameDate(_selectedDate!, _rangeEnd!)) {
      return _dateLabel(_selectedDate!);
    }
    return '${_dateLabel(_selectedDate!)} a ${_dateLabel(_rangeEnd!)}';
  }

  Widget _timelineSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: _inkColor,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _TimelineCalendar extends StatelessWidget {
  const _TimelineCalendar({
    required this.month,
    required this.selectedDate,
    required this.rangeEnd,
    required this.records,
    required this.calendarEntries,
    required this.nonBusinessDays,
    required this.onOpenDate,
    required this.onAddRecord,
  });

  final DateTime month;
  final DateTime? selectedDate;
  final DateTime? rangeEnd;
  final List<_TimelineRecord> records;
  final List<_TimelineCalendarEntry> calendarEntries;
  final List<_TimelineNonBusinessDay> nonBusinessDays;
  final ValueChanged<DateTime> onOpenDate;
  final ValueChanged<DateTime> onAddRecord;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingEmptyCells = firstDay.weekday % 7;
    final today = DateTime.now();

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.34,
      children: [
        for (final day in const [
          'Dom',
          'Seg',
          'Ter',
          'Qua',
          'Qui',
          'Sex',
          'Sab',
        ])
          Center(
            child: Text(
              day,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: _mutedColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        for (var index = 0; index < leadingEmptyCells; index += 1)
          const SizedBox.shrink(),
        for (var day = 1; day <= daysInMonth; day += 1)
          _TimelineDayCell(
            date: DateTime(month.year, month.month, day),
            count: _countForDay(day),
            selected:
                selectedDate?.year == month.year &&
                    selectedDate?.month == month.month &&
                    selectedDate?.day == day ||
                rangeEnd?.year == month.year &&
                    rangeEnd?.month == month.month &&
                    rangeEnd?.day == day,
            inRange: _dateIsInCalendarRange(day),
            today:
                today.year == month.year &&
                today.month == month.month &&
                today.day == day,
            onOpen: () => onOpenDate(DateTime(month.year, month.month, day)),
            onAdd: () => onAddRecord(DateTime(month.year, month.month, day)),
          ),
      ],
    );
  }

  int _countForDay(int day) {
    final date = DateTime(month.year, month.month, day);
    final recordsCount = records.where((record) {
      final date = record.eventDate;
      return date != null &&
          date.year == month.year &&
          date.month == month.month &&
          date.day == day;
    }).length;
    final calendarCount = calendarEntries
        .where((entry) => _sameDate(entry.occurrenceStartsAt, date))
        .length;
    final nonBusinessCount = nonBusinessDays.where((item) {
      if (_sameDate(item.date, date)) {
        return true;
      }
      return item.isRecurringYearly &&
          item.date.month == date.month &&
          item.date.day == date.day;
    }).length;
    return recordsCount + calendarCount + nonBusinessCount;
  }

  bool _dateIsInCalendarRange(int day) {
    if (selectedDate == null || rangeEnd == null) {
      return false;
    }
    return _isDateInRange(
      DateTime(month.year, month.month, day),
      selectedDate!,
      rangeEnd!,
    );
  }
}

class _TimelineDayCell extends StatefulWidget {
  const _TimelineDayCell({
    required this.date,
    required this.count,
    required this.selected,
    required this.inRange,
    required this.today,
    required this.onOpen,
    required this.onAdd,
  });

  final DateTime date;
  final int count;
  final bool selected;
  final bool inRange;
  final bool today;
  final VoidCallback onOpen;
  final VoidCallback onAdd;

  @override
  State<_TimelineDayCell> createState() => _TimelineDayCellState();
}

class _TimelineDayCellState extends State<_TimelineDayCell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.selected
        ? _deepTealColor
        : widget.inRange
        ? _tealColor.withValues(alpha: 0.12)
        : widget.today
        ? _tealColor
        : const Color(0xFFF8FAFB);
    final textColor = widget.selected ? Colors.white : _inkColor;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: widget.onOpen,
                child: Ink(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.selected
                          ? _deepTealColor
                          : widget.inRange || widget.count > 0
                          ? _tealColor.withValues(alpha: 0.34)
                          : _lineColor,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${widget.date.day}',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        constraints: const BoxConstraints(minWidth: 20),
                        height: 18,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: widget.count > 0
                              ? (widget.selected ? Colors.white : _tealColor)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: widget.count > 0
                            ? Text(
                                '${widget.count}',
                                style: TextStyle(
                                  color: widget.selected
                                      ? _deepTealColor
                                      : Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_hovered)
              Center(
                child: Material(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(999),
                  elevation: 4,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: widget.onAdd,
                    child: const SizedBox(
                      width: 42,
                      height: 42,
                      child: Icon(
                        Icons.add_rounded,
                        color: _deepTealColor,
                        size: 30,
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

class _TimelineRecordTile extends StatelessWidget {
  const _TimelineRecordTile({
    required this.record,
    required this.onEdit,
    required this.onRemove,
    this.onOpen,
    this.compact = false,
    this.showActions = true,
  });

  final _TimelineRecord record;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback? onOpen;
  final bool compact;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: record.auditTooltip,
      constraints: const BoxConstraints(maxWidth: 320),
      waitDuration: const Duration(milliseconds: 450),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onOpen,
          child: Ink(
            width: double.infinity,
            padding: EdgeInsets.all(compact ? 10 : 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _lineColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _tealColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        record.monthOnly
                            ? Icons.calendar_view_month_outlined
                            : Icons.event_note_outlined,
                        color: _tealColor,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _inkColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            [
                              record.eventDateLabel.isEmpty
                                  ? 'Sem data'
                                  : record.eventDateLabel,
                              record.referenceMonthLabel,
                              record.categoryLabel,
                            ].join(' | '),
                            style: const TextStyle(
                              color: _mutedColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showActions) ...[
                      IconButton(
                        tooltip: 'Editar',
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Remover',
                        onPressed: onRemove,
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  ],
                ),
                if (!compact) ...[
                  const SizedBox(height: 8),
                  Text(
                    record.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _inkColor, height: 1.3),
                  ),
                ],
                if (record.links.isNotEmpty) ...[
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final link in record.links.take(5))
                        _Tag(
                          label:
                              '${link.entityTypeLabel}: ${link.labelSnapshot}',
                          icon: Icons.link_rounded,
                          color: _deepTealColor,
                          background: _deepTealColor.withValues(alpha: 0.08),
                        ),
                      if (record.links.length > 5)
                        _Tag(
                          label: '+${record.links.length - 5}',
                          icon: Icons.more_horiz_rounded,
                          color: _mutedColor,
                          background: _lineColor.withValues(alpha: 0.60),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimelineCalendarEntryTile extends StatelessWidget {
  const _TimelineCalendarEntryTile({required this.entry, required this.onOpen});

  final _TimelineCalendarEntry entry;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: entry.auditTooltip,
      constraints: const BoxConstraints(maxWidth: 320),
      waitDuration: const Duration(milliseconds: 450),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onOpen,
          child: Ink(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _lineColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _amberColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    entry.kind == 'REMINDER'
                        ? Icons.notifications_active_outlined
                        : Icons.event_note_outlined,
                    color: _amberColor,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _inkColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        [
                          entry.occurrenceStartsAtLabel,
                          entry.kindLabel,
                          entry.statusLabel,
                          entry.targetLabel,
                        ].where((value) => value.isNotEmpty).join(' | '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _mutedColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
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
    );
  }
}

class _TimelineNonBusinessDayTile extends StatelessWidget {
  const _TimelineNonBusinessDayTile({required this.item});

  final _TimelineNonBusinessDay item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _amberColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _amberColor.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_busy_outlined, color: _amberColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              [
                item.name,
                item.dateLabel,
                item.scope == 'BRAZIL_NATIONAL_HOLIDAY'
                    ? 'Feriado nacional'
                    : item.scope,
              ].where((value) => value.isNotEmpty).join(' | '),
              style: const TextStyle(
                color: _inkColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineDayAgendaDialog extends StatelessWidget {
  const _TimelineDayAgendaDialog({
    required this.date,
    required this.records,
    required this.calendarEntries,
    required this.nonBusinessDays,
    required this.onAddRecord,
    required this.onOpenRecord,
    required this.onOpenCalendarEntry,
  });

  final DateTime date;
  final List<_TimelineRecord> records;
  final List<_TimelineCalendarEntry> calendarEntries;
  final List<_TimelineNonBusinessDay> nonBusinessDays;
  final VoidCallback onAddRecord;
  final ValueChanged<_TimelineRecord> onOpenRecord;
  final ValueChanged<_TimelineCalendarEntry> onOpenCalendarEntry;

  @override
  Widget build(BuildContext context) {
    final total =
        records.length + calendarEntries.length + nonBusinessDays.length;
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _dateLabel(date),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Novo registro',
                    onPressed: onAddRecord,
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (total == 0)
                const _TimelineBanner(
                  icon: Icons.event_available_outlined,
                  text: 'Nenhum evento, lembrete ou registro neste dia.',
                  color: _mutedColor,
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: min(
                      MediaQuery.sizeOf(context).height * 0.62,
                      480,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final entry in calendarEntries) ...[
                          _TimelineCalendarEntryTile(
                            entry: entry,
                            onOpen: () => onOpenCalendarEntry(entry),
                          ),
                          const SizedBox(height: 8),
                        ],
                        for (final item in nonBusinessDays) ...[
                          _TimelineNonBusinessDayTile(item: item),
                          const SizedBox(height: 8),
                        ],
                        for (final record in records) ...[
                          _TimelineRecordTile(
                            record: record,
                            compact: true,
                            showActions: false,
                            onOpen: () => onOpenRecord(record),
                            onEdit: () => onOpenRecord(record),
                            onRemove: () => onOpenRecord(record),
                          ),
                          const SizedBox(height: 8),
                        ],
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

class _TimelineRecordDetailsDialog extends StatelessWidget {
  const _TimelineRecordDetailsDialog({required this.record});

  final _TimelineRecord record;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(record.title),
      content: SizedBox(
        width: min(MediaQuery.sizeOf(context).width * 0.88, 560.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(record.description),
              const SizedBox(height: 12),
              _detailsLine(
                'Data',
                record.eventDateLabel.isEmpty
                    ? 'Sem data especifica'
                    : record.eventDateLabel,
              ),
              _detailsLine('Mes', record.referenceMonthLabel),
              _detailsLine('Categoria', record.categoryLabel),
              _detailsLine(
                'Auditoria',
                record.auditTooltip.replaceAll('\n', ' | '),
              ),
              if (record.links.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final link in record.links)
                      _Tag(
                        label: '${link.entityTypeLabel}: ${link.labelSnapshot}',
                        icon: Icons.link_rounded,
                        color: _deepTealColor,
                        background: _deepTealColor.withValues(alpha: 0.08),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop('remove'),
          icon: const Icon(Icons.delete_outline_rounded, size: 18),
          label: const Text('Remover'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop('edit'),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Editar'),
        ),
      ],
    );
  }
}

class _TimelineCalendarEntryDetailsDialog extends StatelessWidget {
  const _TimelineCalendarEntryDetailsDialog({required this.entry});

  final _TimelineCalendarEntry entry;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(entry.title),
      content: SizedBox(
        width: min(MediaQuery.sizeOf(context).width * 0.88, 560.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (entry.description.isNotEmpty) Text(entry.description),
              if (entry.description.isNotEmpty) const SizedBox(height: 12),
              _detailsLine('Quando', entry.occurrenceStartsAtLabel),
              _detailsLine('Tipo', entry.kindLabel),
              _detailsLine('Status', entry.statusLabel),
              _detailsLine('Vinculo', entry.targetLabel),
              _detailsLine('Notificacao', entry.notificationLabel),
              _detailsLine(
                'Auditoria',
                entry.auditTooltip.replaceAll('\n', ' | '),
              ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}

class _TimelineRecordDialog extends StatefulWidget {
  const _TimelineRecordDialog({
    required this.month,
    required this.selectedDate,
    required this.lookups,
    this.record,
  });

  final DateTime month;
  final DateTime? selectedDate;
  final _TimelineLookups lookups;
  final _TimelineRecord? record;

  @override
  State<_TimelineRecordDialog> createState() => _TimelineRecordDialogState();
}

class _TimelineRecordDialogState extends State<_TimelineRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _eventDate;
  late final TextEditingController _manualLabel;
  late final TextEditingController _editJustification;
  late String _category;
  late String _nature;
  late bool _monthOnly;
  var _linkType = 'PROVIDER_COMPANY';
  String? _selectedLookupId;
  final _links = <_TimelineDraftLink>[];

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    _title = TextEditingController(text: record?.title ?? '');
    _description = TextEditingController(text: record?.description ?? '');
    _editJustification = TextEditingController();
    _eventDate = TextEditingController(
      text: record?.eventDate == null
          ? _inputDateFor(widget.selectedDate ?? DateTime.now())
          : _inputDateFor(record!.eventDate!),
    );
    _manualLabel = TextEditingController();
    _category = record?.category ?? 'OPERACIONAL';
    _nature = record?.nature ?? 'NEUTRAL';
    _monthOnly = record?.monthOnly ?? widget.selectedDate == null;
    _links.addAll(
      record?.links.map((link) {
            return _TimelineDraftLink(
              entityType: link.entityType,
              entityPublicId: link.entityPublicId,
              labelSnapshot: link.labelSnapshot,
              notes: link.notes,
            );
          }) ??
          const [],
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _eventDate.dispose();
    _manualLabel.dispose();
    _editJustification.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = min(MediaQuery.sizeOf(context).width * 0.92, 760.0);
    final fieldWidth = width < 620 ? width : (width - 14) / 2;
    return AlertDialog(
      title: Text(widget.record == null ? 'Novo registro' : 'Editar registro'),
      content: SizedBox(
        width: width,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 14,
                  runSpacing: 12,
                  children: [
                    _dialogTextField(
                      width: width,
                      controller: _title,
                      label: 'Titulo',
                      icon: Icons.title_outlined,
                      required: true,
                    ),
                    _dialogTextField(
                      width: width,
                      controller: _description,
                      label: 'Registro',
                      icon: Icons.notes_outlined,
                      minLines: 4,
                      maxLines: 6,
                      required: true,
                    ),
                    if (widget.record != null)
                      _dialogTextField(
                        width: width,
                        controller: _editJustification,
                        label: 'Justificativa da edicao',
                        icon: Icons.edit_note_outlined,
                        maxLines: 2,
                      ),
                    _dialogDropdown(
                      width: fieldWidth,
                      label: 'Categoria',
                      value: _category,
                      values: _timelineCategories,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _category = value);
                        }
                      },
                    ),
                    _dialogDropdown(
                      width: fieldWidth,
                      label: 'Natureza',
                      value: _nature,
                      values: _timelineNatures,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _nature = value);
                        }
                      },
                    ),
                    _dateField(fieldWidth),
                    SizedBox(
                      width: fieldWidth,
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _monthOnly,
                        onChanged: (value) =>
                            setState(() => _monthOnly = value),
                        title: const Text('Registro do mes'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.zero,
                  title: const Text('Vinculos opcionais'),
                  leading: const Icon(Icons.link_rounded),
                  children: [_linksEditor(width, fieldWidth)],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Salvar'),
        ),
      ],
    );
  }

  Widget _dateField(double width) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: _eventDate,
        enabled: !_monthOnly,
        readOnly: true,
        onTap: _monthOnly ? null : _pickDate,
        decoration: InputDecoration(
          labelText: 'Data especifica',
          prefixIcon: const Icon(Icons.event_outlined),
          suffixIcon: IconButton(
            tooltip: 'Selecionar data',
            onPressed: _monthOnly ? null : _pickDate,
            icon: const Icon(Icons.calendar_month_outlined),
          ),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        validator: (value) {
          if (_monthOnly) {
            return null;
          }
          final text = value?.trim() ?? '';
          if (!_isValidInputDate(text)) {
            return 'Use yyyy-mm-dd';
          }
          return null;
        },
      ),
    );
  }

  Widget _linksEditor(double width, double fieldWidth) {
    final options = widget.lookups.optionsFor(_linkType);
    final needsManual =
        options.isEmpty ||
        _linkType == 'CONTRACT_TEXT' ||
        _linkType == 'GROUP' ||
        _linkType == 'CITY' ||
        _linkType == 'OTHER';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 14,
          runSpacing: 12,
          children: [
            _dialogDropdown(
              width: fieldWidth,
              label: 'Tipo de vinculo',
              value: _linkType,
              values: _timelineLinkTypeLabels,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _linkType = value;
                    _selectedLookupId = null;
                    _manualLabel.clear();
                  });
                }
              },
            ),
            if (!needsManual)
              SizedBox(
                width: fieldWidth,
                child: DropdownButtonFormField<String>(
                  initialValue:
                      options.any((item) => item.publicId == _selectedLookupId)
                      ? _selectedLookupId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Selecionar',
                    prefixIcon: Icon(Icons.search_outlined),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    for (final option in options)
                      DropdownMenuItem(
                        value: option.publicId,
                        child: Text(
                          option.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedLookupId = value),
                ),
              )
            else
              _dialogTextField(
                width: fieldWidth,
                controller: _manualLabel,
                label: 'Descricao do vinculo',
                icon: Icons.edit_note_outlined,
              ),
            SizedBox(
              width: fieldWidth,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonalIcon(
                  onPressed: _addLink,
                  icon: const Icon(Icons.add_link_rounded, size: 18),
                  label: const Text('Adicionar vinculo'),
                ),
              ),
            ),
          ],
        ),
        if (_links.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final link in _links)
                InputChip(
                  label: Text(
                    '${_timelineLinkTypeLabels[link.entityType] ?? link.entityType}: ${link.labelSnapshot}',
                  ),
                  onDeleted: () => setState(() => _links.remove(link)),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _dialogTextField({
    required double width,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        validator: required
            ? (value) {
                final text = value?.trim() ?? '';
                return text.isEmpty ? 'Campo obrigatorio' : null;
              }
            : null,
      ),
    );
  }

  Widget _dialogDropdown({
    required double width,
    required String label,
    required String value,
    required Map<String, String> values,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<String>(
        initialValue: values.containsKey(value) ? value : values.keys.first,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.tune_outlined, size: 18),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: [
          for (final entry in values.entries)
            DropdownMenuItem(value: entry.key, child: Text(entry.value)),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _pickDate() async {
    final current =
        DateTime.tryParse(_eventDate.text) ??
        widget.selectedDate ??
        widget.month;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035, 12, 31),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() => _eventDate.text = _inputDateFor(picked));
  }

  void _addLink() {
    final options = widget.lookups.optionsFor(_linkType);
    final selected = options
        .where((item) => item.publicId == _selectedLookupId)
        .firstOrNull;
    final label = selected?.label ?? _manualLabel.text.trim();
    if (label.isEmpty) {
      return;
    }
    setState(() {
      _links.add(
        _TimelineDraftLink(
          entityType: _linkType,
          entityPublicId: selected?.publicId,
          labelSnapshot: label,
        ),
      );
      _selectedLookupId = null;
      _manualLabel.clear();
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).pop(
      _cleanMutationBody({
        'title': _title.text,
        'description': _description.text,
        'category': _category,
        'nature': _nature,
        'referenceMonth': _monthQuery(widget.month),
        'eventDate': _monthOnly ? '' : _eventDate.text,
        'isMonthOnly': _monthOnly,
        'visibility': 'INTERNAL',
        if (widget.record != null) 'editJustification': _editJustification.text,
        'links': [
          for (final link in _links)
            _cleanMutationBody({
              'entityType': link.entityType,
              'entityPublicId': link.entityPublicId,
              'labelSnapshot': link.labelSnapshot,
              'notes': link.notes,
            }),
        ],
      }),
    );
  }
}

class _TimelineDropdownFilter extends StatelessWidget {
  const _TimelineDropdownFilter({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final Map<String, String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: DropdownButtonFormField<String>(
        initialValue: values.containsKey(value) ? value : '',
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: [
          for (final entry in values.entries)
            DropdownMenuItem(value: entry.key, child: Text(entry.value)),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _TimelineBanner extends StatelessWidget {
  const _TimelineBanner({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _mutedColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineApiRepository {
  _TimelineApiRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<_TimelineRecord>> listRecords({
    required String referenceMonth,
    required String search,
    required String category,
    required String entityType,
    required bool monthOnly,
  }) async {
    await _apiClient.ensureDevelopmentSession();
    final data = await _apiClient.getMap(
      'timeline',
      query: {
        'referenceMonth': referenceMonth,
        'perPage': '100',
        if (search.trim().isNotEmpty) 'search': search.trim(),
        if (category.isNotEmpty) 'category': category,
        if (entityType.isNotEmpty) 'entityType': entityType,
        if (monthOnly) 'monthOnly': 'true',
      },
    );
    return _apiMapList(data['items']).map(_timelineRecordFromApi).toList();
  }

  Future<List<_TimelineCalendarEntry>> listCalendarEntries({
    required String from,
    required String to,
  }) async {
    await _apiClient.ensureDevelopmentSession();
    final data = await _apiClient.getMap(
      'agenda',
      query: {'startsAtFrom': from, 'startsAtTo': to},
    );
    return _apiMapList(
      data['items'],
    ).map(_timelineCalendarEntryFromApi).toList();
  }

  Future<List<_TimelineNonBusinessDay>> listNonBusinessDays({
    required String from,
    required String to,
  }) async {
    await _apiClient.ensureDevelopmentSession();
    final data = await _apiClient.getMap(
      'agenda/non-business-days',
      query: {'from': from, 'to': to},
    );
    return _apiMapList(
      data['items'],
    ).map(_timelineNonBusinessDayFromApi).toList();
  }

  Future<void> createRecord(Map<String, dynamic> body) async {
    await _apiClient.postMap('timeline', body: body);
  }

  Future<void> updateRecord(String publicId, Map<String, dynamic> body) async {
    await _apiClient.patchMap('timeline/$publicId', body: body);
  }

  Future<void> removeRecord(String publicId) async {
    await _apiClient.deleteMap('timeline/$publicId');
  }

  Future<_TimelineLookups> loadLookups() async {
    final results = await Future.wait([
      _safeItems('empresas-prestadoras', query: const {'perPage': '100'}),
      _safeItems('clientes', query: const {'perPage': '100'}),
      _safeItems('contratos', query: const {'perPage': '100'}),
      _safeItems('pessoas', query: const {'perPage': '100'}),
    ]);
    return _TimelineLookups(
      providerCompanies: results[0].map(_providerLookupFromApi).toList(),
      clientCompanies: results[1].map(_clientLookupFromApi).toList(),
      contracts: results[2].map(_contractLookupFromApi).toList(),
      people: results[3].map(_personLookupFromApi).toList(),
    );
  }

  Future<List<Map<String, dynamic>>> _safeItems(
    String path, {
    Map<String, String?> query = const {},
  }) async {
    try {
      final data = await _apiClient.getMap(path, query: query);
      return _apiMapList(data['items']);
    } on ApiException {
      return const [];
    }
  }
}

class _TimelineRecord {
  const _TimelineRecord({
    required this.publicId,
    required this.title,
    required this.description,
    required this.category,
    required this.categoryLabel,
    required this.nature,
    required this.referenceMonth,
    required this.referenceMonthLabel,
    required this.eventDate,
    required this.eventDateLabel,
    required this.monthOnly,
    required this.links,
    required this.createdByName,
    required this.updatedByName,
    required this.createdAt,
    required this.updatedAt,
    required this.lastEditJustification,
  });

  final String publicId;
  final String title;
  final String description;
  final String category;
  final String categoryLabel;
  final String nature;
  final DateTime referenceMonth;
  final String referenceMonthLabel;
  final DateTime? eventDate;
  final String eventDateLabel;
  final bool monthOnly;
  final List<_TimelineRecordLink> links;
  final String createdByName;
  final String updatedByName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String lastEditJustification;

  String get auditTooltip => _auditTooltip(
    createdByName: createdByName,
    createdAt: createdAt,
    updatedByName: updatedByName,
    updatedAt: updatedAt,
    lastEditJustification: lastEditJustification,
  );
}

class _TimelineCalendarEntry {
  const _TimelineCalendarEntry({
    required this.publicId,
    required this.title,
    required this.description,
    required this.kind,
    required this.kindLabel,
    required this.statusLabel,
    required this.targetLabel,
    required this.notificationLabel,
    required this.occurrenceStartsAt,
    required this.occurrenceStartsAtLabel,
    required this.createdByName,
    required this.updatedByName,
    required this.createdAt,
    required this.updatedAt,
    required this.lastEditJustification,
  });

  final String publicId;
  final String title;
  final String description;
  final String kind;
  final String kindLabel;
  final String statusLabel;
  final String targetLabel;
  final String notificationLabel;
  final DateTime occurrenceStartsAt;
  final String occurrenceStartsAtLabel;
  final String createdByName;
  final String updatedByName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String lastEditJustification;

  String get auditTooltip => _auditTooltip(
    createdByName: createdByName,
    createdAt: createdAt,
    updatedByName: updatedByName,
    updatedAt: updatedAt,
    lastEditJustification: lastEditJustification,
  );
}

class _TimelineNonBusinessDay {
  const _TimelineNonBusinessDay({
    required this.publicId,
    required this.name,
    required this.scope,
    required this.date,
    required this.dateLabel,
    required this.isRecurringYearly,
  });

  final String publicId;
  final String name;
  final String scope;
  final DateTime date;
  final String dateLabel;
  final bool isRecurringYearly;
}

class _TimelineRecordLink {
  const _TimelineRecordLink({
    required this.entityType,
    required this.entityTypeLabel,
    required this.entityPublicId,
    required this.labelSnapshot,
    required this.notes,
  });

  final String entityType;
  final String entityTypeLabel;
  final String entityPublicId;
  final String labelSnapshot;
  final String notes;
}

class _TimelineDraftLink {
  const _TimelineDraftLink({
    required this.entityType,
    required this.labelSnapshot,
    this.entityPublicId,
    this.notes,
  });

  final String entityType;
  final String? entityPublicId;
  final String labelSnapshot;
  final String? notes;
}

class _TimelineLookups {
  const _TimelineLookups({
    required this.providerCompanies,
    required this.clientCompanies,
    required this.contracts,
    required this.people,
  });

  final List<_TimelineLookupOption> providerCompanies;
  final List<_TimelineLookupOption> clientCompanies;
  final List<_TimelineLookupOption> contracts;
  final List<_TimelineLookupOption> people;

  List<_TimelineLookupOption> optionsFor(String type) {
    return switch (type) {
      'PROVIDER_COMPANY' => providerCompanies,
      'CLIENT_COMPANY' => clientCompanies,
      'CONTRACT' => contracts,
      'PERSON' => people,
      _ => const [],
    };
  }
}

class _TimelineLookupOption {
  const _TimelineLookupOption({required this.publicId, required this.label});

  final String publicId;
  final String label;
}

_TimelineRecord _timelineRecordFromApi(Map<String, dynamic> item) {
  final createdBy = _apiMap(item['createdBy']);
  final updatedBy = _apiMap(item['updatedBy']);
  return _TimelineRecord(
    publicId: _apiText(item['publicId']),
    title: _apiText(item['title'], fallback: 'Registro sem titulo'),
    description: _apiText(item['description']),
    category: _apiText(item['category'], fallback: 'OPERACIONAL'),
    categoryLabel: _apiText(item['categoryLabel'], fallback: 'Operacional'),
    nature: _apiText(item['nature'], fallback: 'NEUTRAL'),
    referenceMonth: _apiDate(item['referenceMonth']) ?? DateTime.now(),
    referenceMonthLabel: _apiText(item['referenceMonthLabel']),
    eventDate: _apiDate(item['eventDate']),
    eventDateLabel: _apiText(item['eventDateLabel']),
    monthOnly: item['monthOnly'] == true,
    links: _apiMapList(item['links']).map(_timelineLinkFromApi).toList(),
    createdByName: _apiText(
      createdBy['name'],
      fallback: _apiText(
        item['createdByUserSystemPublicId'],
        fallback: 'Sistema',
      ),
    ),
    updatedByName: _apiText(updatedBy['name']),
    createdAt: _apiDate(item['createdAt']),
    updatedAt: _apiDate(item['updatedAt']),
    lastEditJustification: _apiText(item['lastEditJustification']),
  );
}

_TimelineCalendarEntry _timelineCalendarEntryFromApi(
  Map<String, dynamic> item,
) {
  final target = _apiMap(item['target']);
  final notification = _apiMap(item['notification']);
  final createdBy = _apiMap(item['createdBy']);
  final updatedBy = _apiMap(item['updatedBy']);
  final occurrence =
      _apiDate(item['occurrenceStartsAt']) ??
      _apiDate(item['startsAt']) ??
      DateTime.fromMillisecondsSinceEpoch(0);
  return _TimelineCalendarEntry(
    publicId: _apiText(item['publicId']),
    title: _apiText(item['title'], fallback: 'Item de calendario'),
    description: _apiText(item['description']),
    kind: _apiText(item['kind'], fallback: 'REMINDER'),
    kindLabel: _apiText(item['kindLabel'], fallback: 'Lembrete'),
    statusLabel: _apiText(
      item['statusLabel'],
      fallback: _apiText(item['status']),
    ),
    targetLabel: _apiText(target['label']),
    notificationLabel: _apiText(notification['policyLabel']),
    occurrenceStartsAt: occurrence,
    occurrenceStartsAtLabel: _apiText(
      item['occurrenceStartsAtLabel'],
      fallback: _apiText(item['startsAtLabel']),
    ),
    createdByName: _apiText(createdBy['name'], fallback: 'Sistema'),
    updatedByName: _apiText(updatedBy['name']),
    createdAt: _apiDate(item['createdAt']),
    updatedAt: _apiDate(item['updatedAt']),
    lastEditJustification: _apiText(item['lastEditJustification']),
  );
}

_TimelineNonBusinessDay _timelineNonBusinessDayFromApi(
  Map<String, dynamic> item,
) {
  final date = _apiDate(item['date']) ?? DateTime.fromMillisecondsSinceEpoch(0);
  return _TimelineNonBusinessDay(
    publicId: _apiText(item['publicId']),
    name: _apiText(item['name'], fallback: 'Dia nao util'),
    scope: _apiText(item['scope']),
    date: date,
    dateLabel: _apiText(item['dateLabel'], fallback: _dateLabel(date)),
    isRecurringYearly: item['isRecurringYearly'] == true,
  );
}

_TimelineRecordLink _timelineLinkFromApi(Map<String, dynamic> item) {
  final type = _apiText(item['entityType'], fallback: 'OTHER');
  return _TimelineRecordLink(
    entityType: type,
    entityTypeLabel: _apiText(
      item['entityTypeLabel'],
      fallback: _timelineLinkTypeLabels[type] ?? 'Outro',
    ),
    entityPublicId: _apiText(item['entityPublicId']),
    labelSnapshot: _apiText(item['labelSnapshot'], fallback: 'Sem rotulo'),
    notes: _apiText(item['notes']),
  );
}

_TimelineLookupOption _providerLookupFromApi(Map<String, dynamic> item) {
  return _TimelineLookupOption(
    publicId: _apiText(item['publicId']),
    label: _apiText(
      item['tradeName'],
      fallback: _apiText(item['legalName'], fallback: 'Prestadora sem nome'),
    ),
  );
}

_TimelineLookupOption _clientLookupFromApi(Map<String, dynamic> item) {
  return _TimelineLookupOption(
    publicId: _apiText(item['publicId']),
    label: _apiText(item['name'], fallback: 'Cliente sem nome'),
  );
}

_TimelineLookupOption _contractLookupFromApi(Map<String, dynamic> item) {
  final provider = _apiMap(item['providerCompany']);
  final client = _apiMap(item['clientCompany']);
  return _TimelineLookupOption(
    publicId: _apiText(item['publicId']),
    label: [
      _apiText(
        provider['tradeName'],
        fallback: _apiText(provider['legalName']),
      ),
      _apiText(client['name']),
      _apiText(item['status']),
    ].where((value) => value.isNotEmpty).join(' | '),
  );
}

_TimelineLookupOption _personLookupFromApi(Map<String, dynamic> item) {
  return _TimelineLookupOption(
    publicId: _apiText(item['publicId']),
    label: _apiText(item['name'], fallback: 'Pessoa sem nome'),
  );
}

String _monthQuery(DateTime value) {
  return '${value.year}-${value.month.toString().padLeft(2, '0')}';
}

String _dateQuery(DateTime value) {
  return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}

String _monthLabel(DateTime value) {
  const labels = [
    'Janeiro',
    'Fevereiro',
    'Marco',
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
  return '${labels[value.month - 1]} ${value.year}';
}

String _dateLabel(DateTime value) {
  return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}

bool _sameDate(DateTime? left, DateTime? right) {
  return left != null &&
      right != null &&
      left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

bool _isDateInRange(DateTime date, DateTime start, DateTime end) {
  final normalizedStart = DateTime(start.year, start.month, start.day);
  final normalizedEnd = DateTime(end.year, end.month, end.day);
  final normalizedDate = DateTime(date.year, date.month, date.day);
  final from = normalizedStart.isBefore(normalizedEnd)
      ? normalizedStart
      : normalizedEnd;
  final to = normalizedStart.isBefore(normalizedEnd)
      ? normalizedEnd
      : normalizedStart;
  return !normalizedDate.isBefore(from) && !normalizedDate.isAfter(to);
}

String _auditTooltip({
  required String createdByName,
  required DateTime? createdAt,
  required String updatedByName,
  required DateTime? updatedAt,
  required String lastEditJustification,
}) {
  final createdLine =
      'Por ${createdByName.isEmpty ? 'Sistema' : createdByName}, ${_shortDateTimeLabel(createdAt)}';
  if (updatedByName.isEmpty && lastEditJustification.isEmpty) {
    return createdLine;
  }
  final justification = _limitText(lastEditJustification, 30);
  final updateLine = [
    'Ultima Edicao: ${updatedByName.isEmpty ? 'Sistema' : updatedByName}',
    'em: ${_shortDateTimeLabel(updatedAt)}',
    if (justification.isNotEmpty) '- $justification',
  ].join(' ');
  return '$createdLine\n$updateLine';
}

String _limitText(String value, int maxLength) {
  final text = value.trim();
  if (text.length <= maxLength) {
    return text;
  }
  return text.substring(0, maxLength).trimRight();
}

String _shortDateTimeLabel(DateTime? value) {
  if (value == null) {
    return '--/--/--, --:--';
  }
  final local = value.isUtc ? value.toLocal() : value;
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = (local.year % 100).toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month/$year, $hour:$minute';
}

Widget _detailsLine(String label, String value) {
  if (value.trim().isEmpty) {
    return const SizedBox.shrink();
  }
  return Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: _inkColor, height: 1.25),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          TextSpan(text: value),
        ],
      ),
    ),
  );
}
