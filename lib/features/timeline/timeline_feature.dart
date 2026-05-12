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
  var _records = <_TimelineRecord>[];
  var _category = '';
  var _entityType = '';
  bool _monthOnly = false;
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
    final selectedRecords = _selectedDate == null
        ? _records
        : _records.where((record) {
            final date = record.eventDate;
            return date != null &&
                date.year == _selectedDate!.year &&
                date.month == _selectedDate!.month &&
                date.day == _selectedDate!.day;
          }).toList();
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
                    records: _records,
                    onSelectDate: (date) {
                      setState(() => _selectedDate = date);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _recordsPanel(context, selectedRecords, undatedRecords),
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
      ],
    );
  }

  Widget _recordsPanel(
    BuildContext context,
    List<_TimelineRecord> selectedRecords,
    List<_TimelineRecord> undatedRecords,
  ) {
    final visible = _selectedDate == null ? _records : selectedRecords;
    final title = _selectedDate == null
        ? 'Registros de ${_monthLabel(_month)}'
        : 'Registros de ${_dateLabel(_selectedDate!)}';

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
                label: '${visible.length} registros',
                icon: Icons.format_list_bulleted_rounded,
                color: _deepTealColor,
                background: _deepTealColor.withValues(alpha: 0.09),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading && _records.isEmpty)
            const LinearProgressIndicator(minHeight: 2)
          else if (visible.isEmpty)
            const _TimelineBanner(
              icon: Icons.event_available_outlined,
              text: 'Nenhum registro encontrado para o recorte atual.',
              color: _mutedColor,
            )
          else
            for (final record in visible) ...[
              _TimelineRecordTile(
                record: record,
                onEdit: () => _openRecordDialog(record: record),
                onRemove: () => _confirmRemove(record),
              ),
              const SizedBox(height: 10),
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
      final records = await _repository.listRecords(
        referenceMonth: _monthQuery(_month),
        search: _searchController.text,
        category: _category,
        entityType: _entityType,
        monthOnly: _monthOnly,
      );
      if (!mounted) {
        return;
      }
      setState(() => _records = records);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _records = const [];
        _error =
            'API indisponivel para Timeline (${error.code}). Nenhum dado mock foi carregado.';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openRecordDialog({_TimelineRecord? record}) async {
    final lookups = await _repository.loadLookups();
    if (!mounted) {
      return;
    }
    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _TimelineRecordDialog(
        month: _month,
        selectedDate: _selectedDate,
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
}

class _TimelineCalendar extends StatelessWidget {
  const _TimelineCalendar({
    required this.month,
    required this.selectedDate,
    required this.records,
    required this.onSelectDate,
  });

  final DateTime month;
  final DateTime? selectedDate;
  final List<_TimelineRecord> records;
  final ValueChanged<DateTime> onSelectDate;

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
                selectedDate?.day == day,
            today:
                today.year == month.year &&
                today.month == month.month &&
                today.day == day,
            onTap: () => onSelectDate(DateTime(month.year, month.month, day)),
          ),
      ],
    );
  }

  int _countForDay(int day) {
    return records.where((record) {
      final date = record.eventDate;
      return date != null &&
          date.year == month.year &&
          date.month == month.month &&
          date.day == day;
    }).length;
  }
}

class _TimelineDayCell extends StatelessWidget {
  const _TimelineDayCell({
    required this.date,
    required this.count,
    required this.selected,
    required this.today,
    required this.onTap,
  });

  final DateTime date;
  final int count;
  final bool selected;
  final bool today;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? _deepTealColor
        : today
        ? _tealColor
        : const Color(0xFFF8FAFB);
    final textColor = selected ? Colors.white : _inkColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? _deepTealColor
                  : count > 0
                  ? _tealColor.withValues(alpha: 0.34)
                  : _lineColor,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day}',
                style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                constraints: const BoxConstraints(minWidth: 20),
                height: 18,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: count > 0
                      ? (selected ? Colors.white : _tealColor)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: count > 0
                    ? Text(
                        '$count',
                        style: TextStyle(
                          color: selected ? _deepTealColor : Colors.white,
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
    );
  }
}

class _TimelineRecordTile extends StatelessWidget {
  const _TimelineRecordTile({
    required this.record,
    required this.onEdit,
    required this.onRemove,
    this.compact = false,
  });

  final _TimelineRecord record;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    label: '${link.entityTypeLabel}: ${link.labelSnapshot}',
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
