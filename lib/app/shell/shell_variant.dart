part of '../app.dart';

enum _ShellVariant { legacy, crm }

extension on _ShellVariant {
  String get label => switch (this) {
    _ShellVariant.legacy => 'shell legado',
    _ShellVariant.crm => 'crm shell',
  };
}
