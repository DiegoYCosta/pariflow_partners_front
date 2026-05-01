part of '../../app/app.dart';

enum _SensitiveNoteClassification {
  behavioralSignal,
  routineContext,
  familyContext,
  trainingOrSkill,
  personalContext,
  operationalRisk,
}

extension on _SensitiveNoteClassification {
  String get label => switch (this) {
    _SensitiveNoteClassification.behavioralSignal => 'comportamento',
    _SensitiveNoteClassification.routineContext => 'rotina',
    _SensitiveNoteClassification.familyContext => 'familia',
    _SensitiveNoteClassification.trainingOrSkill => 'habilidade',
    _SensitiveNoteClassification.personalContext => 'contexto pessoal',
    _SensitiveNoteClassification.operationalRisk => 'risco operacional',
  };

  IconData get icon => switch (this) {
    _SensitiveNoteClassification.behavioralSignal =>
      Icons.psychology_alt_outlined,
    _SensitiveNoteClassification.routineContext =>
      Icons.event_note_outlined,
    _SensitiveNoteClassification.familyContext => Icons.family_restroom_outlined,
    _SensitiveNoteClassification.trainingOrSkill =>
      Icons.workspace_premium_outlined,
    _SensitiveNoteClassification.personalContext => Icons.person_pin_outlined,
    _SensitiveNoteClassification.operationalRisk => Icons.warning_amber_rounded,
  };
}

class _SensitiveNoteTag {
  const _SensitiveNoteTag({
    required this.label,
    required this.note,
    required this.classification,
    required this.color,
    required this.sortOrder,
    this.requiresLoginToView = true,
    this.requiresLoginToCreate = false,
  }) : assert(note.length <= 350);

  final String label;
  final String note;
  final _SensitiveNoteClassification classification;
  final Color color;
  final int sortOrder;
  final bool requiresLoginToView;
  final bool requiresLoginToCreate;

  String get accessSummary {
    final createSummary = requiresLoginToCreate
        ? 'envio com sessao'
        : 'envio sem login';
    final viewSummary = requiresLoginToView
        ? 'consulta protegida'
        : 'consulta livre';
    return '$createSummary | $viewSummary';
  }
}
