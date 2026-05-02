part of '../../app/app.dart';

class _PeopleWorkspace extends StatelessWidget {
  const _PeopleWorkspace({
    required this.viewerProfile,
    required this.selectedIndex,
    required this.onSelectItem,
  });

  final _ViewerAccessProfile viewerProfile;
  final int selectedIndex;
  final ValueChanged<int> onSelectItem;

  @override
  Widget build(BuildContext context) {
    final data = _peopleWorkspaceData;
    final safeIndex = min(max(selectedIndex, 0), data.items.length - 1);
    final selectedItem = data.items[safeIndex];
    final profile = _personProfileFor(selectedItem);
    final visibleAttachments = selectedItem.attachments
        .where(
          (attachment) => attachment.accessPolicy.canViewerRead(viewerProfile),
        )
        .toList();
    final visibleNotes = [...selectedItem.sensitiveNotes]
      ..retainWhere((note) => note.accessPolicy.canViewerRead(viewerProfile))
      ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
    final sensitiveSections = _buildSensitiveSections(visibleNotes);

    return Column(
      children: [
        _Panel(
          padding: const EdgeInsets.all(24),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 18,
            spacing: 18,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'People',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Ficha individual baseada em identidade, employment links, sensitive information e attachments, sem quebrar o envelope atual de acesso e compartilhamento.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: _mutedColor),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: DropdownButtonFormField<int>(
                  value: safeIndex,
                  decoration: InputDecoration(
                    labelText: 'Employee record',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: _lineColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: _lineColor),
                    ),
                  ),
                  items: [
                    for (final entry in data.items.indexed)
                      DropdownMenuItem<int>(
                        value: entry.$1,
                        child: Text(
                          '${entry.$2.title} - ${entry.$2.publicId}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onSelectItem(value);
                    }
                  },
                ),
              ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Tag(
                    label: selectedItem.publicId,
                    icon: Icons.badge_outlined,
                    color: _slateColor,
                    background: _slateColor.withValues(alpha: 0.12),
                  ),
                  _Tag(
                    label: profile.statusLabel,
                    icon: Icons.circle,
                    color: profile.statusColor,
                    background: profile.statusColor.withValues(alpha: 0.12),
                  ),
                  _Tag(
                    label: '${profile.employmentLinks.length} employment links',
                    icon: Icons.link_rounded,
                    color: _tealColor,
                    background: _tealColor.withValues(alpha: 0.12),
                  ),
                  _Tag(
                    label: '${visibleNotes.length} sensitive tags visible',
                    icon: viewerProfile.canViewSensitive
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: _amberColor,
                    background: _amberColor.withValues(alpha: 0.12),
                  ),
                  _Tag(
                    label: '${visibleAttachments.length} attachments visible',
                    icon: Icons.attach_file_rounded,
                    color: _roseColor,
                    background: _roseColor.withValues(alpha: 0.12),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1540;
            final medium = constraints.maxWidth >= 1120;
            final profilePanel = _PeopleProfilePanel(
              item: selectedItem,
              profile: profile,
            );
            final linksPanel = _EmploymentLinksPanel(profile: profile);
            final sideColumn = _PeopleSideColumn(
              viewerProfile: viewerProfile,
              item: selectedItem,
              sections: sensitiveSections,
              attachments: visibleAttachments,
            );

            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: profilePanel),
                  const SizedBox(width: 24),
                  Expanded(flex: 6, child: linksPanel),
                  const SizedBox(width: 24),
                  Expanded(flex: 3, child: sideColumn),
                ],
              );
            }

            if (medium) {
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: profilePanel),
                      const SizedBox(width: 24),
                      Expanded(flex: 7, child: linksPanel),
                    ],
                  ),
                  const SizedBox(height: 24),
                  sideColumn,
                ],
              );
            }

            return Column(
              children: [
                profilePanel,
                const SizedBox(height: 24),
                linksPanel,
                const SizedBox(height: 24),
                sideColumn,
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PeopleProfilePanel extends StatelessWidget {
  const _PeopleProfilePanel({required this.item, required this.profile});

  final _EntityItem item;
  final _PersonProfileData profile;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert_rounded),
              color: _mutedColor,
            ),
          ),
          Center(
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    item.color.withValues(alpha: 0.30),
                    const Color(0xFFE7EDF1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: item.color.withValues(alpha: 0.28),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _initialsFor(item.title),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 54,
                  letterSpacing: -2.2,
                  color: _inkColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            item.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: 42,
              letterSpacing: -1.8,
              height: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            profile.roleTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: item.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: profile.statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 12, color: profile.statusColor),
                const SizedBox(width: 10),
                Text(
                  profile.statusLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: profile.statusColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: _lineColor),
          const SizedBox(height: 18),
          for (final field in profile.profileFields) ...[
            _ProfileFieldRow(field: field),
            const SizedBox(height: 18),
          ],
          const SizedBox(height: 8),
          const Divider(color: _lineColor),
          const SizedBox(height: 24),
          Text('Manager', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: _slateColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _initialsFor(profile.managerName),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.managerName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.managerRole,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _PeopleMetaBlock(
                  icon: Icons.groups_outlined,
                  label: 'Team',
                  value: profile.teamLabel,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _PeopleMetaBlock(
                  icon: Icons.domain_outlined,
                  label: 'Department',
                  value: profile.departmentLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileFieldRow extends StatelessWidget {
  const _ProfileFieldRow({required this.field});

  final _PersonInfoField field;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(field.icon, color: _mutedColor, size: 24),
        const SizedBox(width: 14),
        SizedBox(
          width: 128,
          child: Text(
            field.label,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: _mutedColor),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            field.value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}

class _PeopleMetaBlock extends StatelessWidget {
  const _PeopleMetaBlock({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _lineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _mutedColor),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: _mutedColor),
          ),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _EmploymentLinksPanel extends StatefulWidget {
  const _EmploymentLinksPanel({required this.profile});

  final _PersonProfileData profile;

  @override
  State<_EmploymentLinksPanel> createState() => _EmploymentLinksPanelState();
}

class _EmploymentLinksPanelState extends State<_EmploymentLinksPanel> {
  bool _showFullHistory = false;

  @override
  Widget build(BuildContext context) {
    final links = widget.profile.employmentLinks;
    final canCollapse = links.length > 3;
    final visibleLinks = canCollapse && !_showFullHistory
        ? links.take(3).toList()
        : links;

    return _Panel(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 16,
            spacing: 16,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.link_rounded, size: 34, color: _slateColor),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Employment Links',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(fontSize: 32),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.profile.timelineSummary,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: _mutedColor),
                      ),
                    ],
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Link'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          for (final entry in visibleLinks.indexed) ...[
            _EmploymentTimelineEntry(
              record: entry.$2,
              isLast: entry.$1 == visibleLinks.length - 1,
            ),
            const SizedBox(height: 18),
          ],
          if (canCollapse)
            Align(
              alignment: Alignment.center,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _showFullHistory = !_showFullHistory;
                  });
                },
                icon: Icon(
                  _showFullHistory
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                ),
                label: Text(
                  _showFullHistory
                      ? 'Hide Earlier History'
                      : 'Show Earlier History',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmploymentTimelineEntry extends StatelessWidget {
  const _EmploymentTimelineEntry({required this.record, required this.isLast});

  final _EmploymentLinkRecord record;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 128,
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Text(
              record.periodLabel,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: record.isCurrent ? _tealColor : _mutedColor,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 44,
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: record.isCurrent
                      ? record.accent.withValues(alpha: 0.14)
                      : Colors.white,
                  border: Border.all(
                    color: record.isCurrent ? record.accent : _lineColor,
                    width: 3,
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 170,
                  color: record.isCurrent
                      ? record.accent.withValues(alpha: 0.55)
                      : _lineColor,
                ),
            ],
          ),
        ),
        const SizedBox(width: 18),
        Expanded(child: _EmploymentLinkCard(record: record)),
      ],
    );
  }
}

class _EmploymentLinkCard extends StatelessWidget {
  const _EmploymentLinkCard({required this.record});

  final _EmploymentLinkRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _lineColor),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: record.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: Text(
                  record.brandMonogram,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: record.accent,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.companyName,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(fontSize: 26),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        Text(
                          record.roleTitle,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        if (record.isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _tealColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Current',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: _tealColor),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('View Details'),
                  ),
                  const SizedBox(height: 12),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _mutedColor,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: _lineColor),
          const SizedBox(height: 16),
          Wrap(
            spacing: 26,
            runSpacing: 14,
            children: [
              _EmploymentMetaLine(
                icon: Icons.calendar_month_outlined,
                value: record.fullDateLabel,
              ),
              _EmploymentMetaLine(
                icon: Icons.location_on_outlined,
                value: record.locationLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmploymentMetaLine extends StatelessWidget {
  const _EmploymentMetaLine({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _mutedColor, size: 24),
        const SizedBox(width: 12),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: _mutedColor),
        ),
      ],
    );
  }
}

class _PeopleSideColumn extends StatelessWidget {
  const _PeopleSideColumn({
    required this.viewerProfile,
    required this.item,
    required this.sections,
    required this.attachments,
  });

  final _ViewerAccessProfile viewerProfile;
  final _EntityItem item;
  final List<_SensitiveSectionGroup> sections;
  final List<_AttachmentRecord> attachments;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SensitiveInformationPanel(
          viewerProfile: viewerProfile,
          sections: sections,
        ),
        const SizedBox(height: 18),
        _AttachmentsPanel(
          viewerProfile: viewerProfile,
          item: item,
          attachments: attachments,
        ),
      ],
    );
  }
}

class _SensitiveInformationPanel extends StatelessWidget {
  const _SensitiveInformationPanel({
    required this.viewerProfile,
    required this.sections,
  });

  final _ViewerAccessProfile viewerProfile;
  final List<_SensitiveSectionGroup> sections;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: _slateColor, size: 30),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Sensitive Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Icon(
                viewerProfile.canViewSensitive
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: _mutedColor,
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: _lineColor),
          if (!viewerProfile.canViewSensitive || sections.isEmpty) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _lineColor),
              ),
              child: Text(
                viewerProfile.canViewSensitive
                    ? 'Nao ha tags sensiveis compartilhadas com este perfil para esta ficha.'
                    : 'Entrada publica ou perfil sem compartilhamento ativo. O front continua ocultando o conteudo protegido que a API nao liberar.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
              ),
            ),
          ] else ...[
            const SizedBox(height: 6),
            for (final section in sections)
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  splashColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 14),
                  leading: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: section.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(
                    section.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final note in section.notes)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: section.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              note.label,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: section.color),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _AttachmentsPanel extends StatelessWidget {
  const _AttachmentsPanel({
    required this.viewerProfile,
    required this.item,
    required this.attachments,
  });

  final _ViewerAccessProfile viewerProfile;
  final _EntityItem item;
  final List<_AttachmentRecord> attachments;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.attach_file_rounded,
                color: _slateColor,
                size: 30,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Attachments',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              OutlinedButton(onPressed: () {}, child: const Text('Upload')),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: _lineColor),
          if (attachments.isEmpty) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _lineColor),
              ),
              child: Text(
                viewerProfile.canViewSensitive
                    ? 'Nenhum anexo compartilhado com este perfil para ${item.title}.'
                    : 'Sem login ou sem compartilhamento ativo: anexos protegidos permanecem ocultos.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
              ),
            ),
          ] else ...[
            const SizedBox(height: 4),
            for (final attachment in attachments) ...[
              _AttachmentRow(attachment: attachment),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('View All Attachments'),
            ),
          ],
        ],
      ),
    );
  }
}

class _AttachmentRow extends StatelessWidget {
  const _AttachmentRow({required this.attachment});

  final _AttachmentRecord attachment;

  @override
  Widget build(BuildContext context) {
    final icon = _attachmentIconFor(attachment.title);
    final iconColor = _attachmentColorFor(attachment);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _lineColor),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  '${attachment.updatedAtLabel} - ${attachment.status}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Icon(
            attachment.canDownload
                ? Icons.download_rounded
                : Icons.lock_outline_rounded,
            color: _mutedColor,
          ),
        ],
      ),
    );
  }
}

List<_SensitiveSectionGroup> _buildSensitiveSections(
  List<_SensitiveNoteTag> notes,
) {
  final groups = <String, _SensitiveSectionGroup>{};

  for (final note in notes) {
    final title = switch (note.classification) {
      _SensitiveNoteClassification.behavioralSignal => 'Behavioral',
      _SensitiveNoteClassification.familyContext ||
      _SensitiveNoteClassification.personalContext ||
      _SensitiveNoteClassification.routineContext => 'Personal Context',
      _SensitiveNoteClassification.trainingOrSkill => 'Career & Skills',
      _SensitiveNoteClassification.operationalRisk => 'Operational Risk',
    };

    final color = switch (note.classification) {
      _SensitiveNoteClassification.behavioralSignal => const Color(0xFF4CAF50),
      _SensitiveNoteClassification.familyContext ||
      _SensitiveNoteClassification.personalContext ||
      _SensitiveNoteClassification.routineContext => const Color(0xFFF2A33A),
      _SensitiveNoteClassification.trainingOrSkill => const Color(0xFF8B6BD8),
      _SensitiveNoteClassification.operationalRisk => const Color(0xFF5E8DEE),
    };

    final existing = groups[title];
    if (existing == null) {
      groups[title] = _SensitiveSectionGroup(
        title: title,
        color: color,
        notes: [note],
      );
      continue;
    }

    groups[title] = _SensitiveSectionGroup(
      title: existing.title,
      color: existing.color,
      notes: [...existing.notes, note],
    );
  }

  final ordered = groups.values.toList()
    ..sort((left, right) => left.title.compareTo(right.title));
  return ordered;
}

IconData _attachmentIconFor(String title) {
  final lower = title.toLowerCase();
  if (lower.endsWith('.pdf')) {
    return Icons.picture_as_pdf_outlined;
  }
  if (lower.endsWith('.xlsx') ||
      lower.endsWith('.xls') ||
      lower.endsWith('.csv')) {
    return Icons.table_chart_outlined;
  }
  if (lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.png') ||
      lower.endsWith('.webp')) {
    return Icons.image_outlined;
  }
  return Icons.insert_drive_file_outlined;
}

Color _attachmentColorFor(_AttachmentRecord attachment) {
  final lower = attachment.title.toLowerCase();
  if (lower.endsWith('.pdf')) {
    return const Color(0xFFE8503A);
  }
  if (lower.endsWith('.xlsx') ||
      lower.endsWith('.xls') ||
      lower.endsWith('.csv')) {
    return const Color(0xFF2E9C4A);
  }
  return attachment.classification.color;
}

class _SensitiveSectionGroup {
  const _SensitiveSectionGroup({
    required this.title,
    required this.color,
    required this.notes,
  });

  final String title;
  final Color color;
  final List<_SensitiveNoteTag> notes;
}

class _PersonProfileData {
  const _PersonProfileData({
    required this.roleTitle,
    required this.statusLabel,
    required this.statusColor,
    required this.profileFields,
    required this.managerName,
    required this.managerRole,
    required this.teamLabel,
    required this.departmentLabel,
    required this.timelineSummary,
    required this.employmentLinks,
  });

  final String roleTitle;
  final String statusLabel;
  final Color statusColor;
  final List<_PersonInfoField> profileFields;
  final String managerName;
  final String managerRole;
  final String teamLabel;
  final String departmentLabel;
  final String timelineSummary;
  final List<_EmploymentLinkRecord> employmentLinks;
}

class _PersonInfoField {
  const _PersonInfoField({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _EmploymentLinkRecord {
  const _EmploymentLinkRecord({
    required this.periodLabel,
    required this.companyName,
    required this.roleTitle,
    required this.fullDateLabel,
    required this.locationLabel,
    required this.brandMonogram,
    required this.accent,
    this.isCurrent = false,
  });

  final String periodLabel;
  final String companyName;
  final String roleTitle;
  final String fullDateLabel;
  final String locationLabel;
  final String brandMonogram;
  final Color accent;
  final bool isCurrent;
}
