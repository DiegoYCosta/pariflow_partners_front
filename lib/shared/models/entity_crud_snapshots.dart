part of '../../app/app.dart';

class _ProviderCompanyCrudSnapshot {
  const _ProviderCompanyCrudSnapshot({
    required this.publicId,
    required this.legalName,
    required this.tradeName,
    required this.document,
    required this.status,
    required this.email,
    required this.phone,
    required this.notes,
  });

  final String publicId;
  final String legalName;
  final String tradeName;
  final String document;
  final String status;
  final String email;
  final String phone;
  final String notes;
}

class _ClientCompanyCrudSnapshot {
  const _ClientCompanyCrudSnapshot({
    required this.publicId,
    required this.name,
    required this.document,
    required this.clientType,
    required this.status,
    required this.contactName,
    required this.city,
    required this.state,
  });

  final String publicId;
  final String name;
  final String document;
  final String clientType;
  final String status;
  final String contactName;
  final String city;
  final String state;
}

class _ContractCrudSnapshot {
  const _ContractCrudSnapshot({
    required this.publicId,
    required this.providerCompanyPublicId,
    required this.clientCompanyPublicId,
    required this.contractTypePublicId,
    required this.contractModelPublicId,
    required this.startsAtInput,
    required this.endsAtInput,
    required this.status,
    required this.notes,
  });

  final String publicId;
  final String providerCompanyPublicId;
  final String clientCompanyPublicId;
  final String contractTypePublicId;
  final String contractModelPublicId;
  final String startsAtInput;
  final String endsAtInput;
  final String status;
  final String notes;
}

class _ContractPositionRecord {
  const _ContractPositionRecord({
    required this.publicId,
    required this.servicePublicId,
    required this.serviceName,
    required this.name,
    required this.location,
    required this.shift,
    required this.schedule,
    required this.requirements,
    required this.status,
  });

  final String publicId;
  final String servicePublicId;
  final String serviceName;
  final String name;
  final String location;
  final String shift;
  final String schedule;
  final String requirements;
  final String status;
}
