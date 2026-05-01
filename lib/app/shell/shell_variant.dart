part of '../app.dart';

enum _ShellVariant { legacy, crm }

extension on _ShellVariant {
  String get label => switch (this) {
    _ShellVariant.legacy => 'shell legado',
    _ShellVariant.crm => 'crm shell',
  };

  String get rolloutSummary => switch (this) {
    _ShellVariant.legacy => 'fluxo atual preservado',
    _ShellVariant.crm => 'preview controlado do novo layout',
  };
}
