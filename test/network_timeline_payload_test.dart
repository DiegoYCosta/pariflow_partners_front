import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pariflow_partners/app/app.dart';

void main() {
  test('parses enveloped network timeline payload', () {
    final payload = _fixtureMap();

    final summary = debugNetworkTimelinePayloadSummary(payload);

    expect(summary['periodPreset'], '1y');
    expect(summary['periodFrom'], '2025-05-16');
    expect(summary['periodTo'], '2026-05-16');
    expect(summary['contractsCount'], 1);
    expect(summary['positionsCount'], 1);
    expect(summary['allocationsCount'], 1);
    expect(summary['collaboratorsCount'], 1);
    expect(summary['eventsCount'], 2);
    expect(summary['snapshotContractsCount'], 1);
    expect(summary['snapshotPositionsCount'], 1);
    expect(summary['snapshotCollaboratorsCount'], 1);
    expect(summary['warningsCount'], 1);
    expect(summary['firstWarningCode'], 'employment_move_unstructured');
    expect(summary['firstMoveHasStructuredLink'], isFalse);
    expect(summary['metaTraceId'], 'req_network_timeline_test');
  });

  test('parses direct data network timeline fixture', () {
    final payload = _fixtureMap();
    final data = (payload['data'] as Map).cast<String, dynamic>();

    final summary = debugNetworkTimelinePayloadSummary(data);

    expect(summary['contractsCount'], 1);
    expect(summary['eventsCount'], 2);
    expect(summary['metaTraceId'], '');
  });

  test('parses valid empty network timeline payload', () {
    final summary = debugNetworkTimelinePayloadSummary({
      'data': {
        'period': {'preset': '1y', 'from': '2025-01-01', 'to': '2026-01-01'},
        'focus': {},
        'layers': {'contracts': [], 'collaborators': [], 'events': []},
        'currentSnapshot': {
          'contracts': [],
          'positions': [],
          'collaborators': [],
        },
        'legend': {'eventTypes': [], 'relationshipStates': []},
        'warnings': [],
      },
      'meta': {'traceId': 'req_empty_timeline_test'},
    });

    expect(summary['contractsCount'], 0);
    expect(summary['positionsCount'], 0);
    expect(summary['eventsCount'], 0);
    expect(summary['warningsCount'], 0);
    expect(summary['metaTraceId'], 'req_empty_timeline_test');
  });

  test('validates target volume layout and viewport culling', () {
    final payload = _targetVolumePayload(
      contractsCount: 120,
      positionsCount: 500,
      allocationsCount: 3000,
      structuredMovesCount: 240,
    );

    final topViewport = debugNetworkTimelineCullingSummary(
      payload,
      viewportWidth: 1366,
      visibleTop: 0,
      visibleHeight: 900,
    );

    expect(topViewport['totalContracts'], 120);
    expect(topViewport['totalPositions'], 500);
    expect(topViewport['totalAllocations'], 3000);
    expect(topViewport['totalEvents'], 240);
    expect(topViewport['totalStructuredMoves'], 240);
    expect(topViewport['visibleContracts'], greaterThan(0));
    expect(topViewport['visibleContracts'], lessThan(120));
    expect(topViewport['visiblePositions'], lessThan(500));
    expect(topViewport['visibleAllocations'], 0);
    expect(topViewport['visibleRowLabels'], lessThan(80));

    final collaboratorViewport = debugNetworkTimelineCullingSummary(
      payload,
      viewportWidth: 1366,
      visibleTop: 25680,
      visibleHeight: 900,
    );

    expect(collaboratorViewport['visibleAllocations'], greaterThan(0));
    expect(collaboratorViewport['visibleAllocations'], lessThan(3000));
    expect(collaboratorViewport['visibleRowLabels'], lessThan(80));

    final sceneHeight = (topViewport['sceneHeight'] as num).toDouble();
    final eventViewport = debugNetworkTimelineCullingSummary(
      payload,
      viewportWidth: 1366,
      visibleLeft: 1200,
      visibleWidth: 700,
      visibleTop: sceneHeight - 160,
      visibleHeight: 220,
    );

    expect(eventViewport['visibleEvents'], greaterThan(0));
    expect(eventViewport['visibleEvents'], lessThan(240));
    expect(eventViewport['visibleStructuredMoves'], greaterThan(0));
  });
}

Map<String, dynamic> _fixtureMap() {
  return (jsonDecode(_fixtureJson) as Map).cast<String, dynamic>();
}

Map<String, dynamic> _targetVolumePayload({
  required int contractsCount,
  required int positionsCount,
  required int allocationsCount,
  required int structuredMovesCount,
}) {
  final contracts = [
    for (var index = 0; index < contractsCount; index++)
      {
        'publicId': _id('ctr', index),
        'providerCompanyPublicId': 'emp_root_001',
        'providerCompanyName': 'PariFlow Services',
        'clientCompanyPublicId': _id('cli', index),
        'clientCompanyName': 'Cliente ${index + 1}',
        'displayName': 'Contrato ${index + 1}',
        'startsAt': '2024-01-01',
        'endsAt': index.isEven ? null : '2026-01-01',
        'status': index.isEven ? 'active' : 'historical',
        'positions': <Map<String, dynamic>>[],
      },
  ];

  for (var index = 0; index < positionsCount; index++) {
    final contractIndex = index % contractsCount;
    final position = {
      'publicId': _id('pos', index),
      'contractPublicId': _id('ctr', contractIndex),
      'displayName': 'Posto ${index + 1}',
      'serviceName': index.isEven ? 'Portaria' : 'Recepcao',
      'location': 'Unidade ${(index % 24) + 1}',
      'shift': index.isEven ? 'Noturno' : 'Comercial',
      'schedule': index.isEven ? '12x36' : '5x2',
      'status': index.isEven ? 'active' : 'historical',
      'startsAt': '2024-01-01',
      'endsAt': null,
      'dateSource': 'contract',
      'allocations': <Map<String, dynamic>>[],
    };
    (contracts[contractIndex]['positions'] as List<Map<String, dynamic>>).add(
      position,
    );
  }

  final positions = [
    for (final contract in contracts)
      ...(contract['positions'] as List<Map<String, dynamic>>),
  ];
  final collaborators = <Map<String, dynamic>>[];

  for (var index = 0; index < allocationsCount; index++) {
    final position = positions[index % positions.length];
    final contractPublicId = position['contractPublicId'] as String;
    final employmentLinkPublicId = _id('vin', index);
    final personPublicId = _id('pes', index);
    final startsAt = '2024-${((index % 12) + 1).toString().padLeft(2, '0')}-01';
    final status = index % 5 == 0 ? 'historical' : 'active';
    final allocation = {
      'employmentLinkPublicId': employmentLinkPublicId,
      'personPublicId': personPublicId,
      'personName': 'Colaborador ${index + 1}',
      'providerCompanyPublicId': 'emp_root_001',
      'contractPublicId': contractPublicId,
      'positionPublicId': position['publicId'],
      'startsAt': startsAt,
      'endsAt': status == 'active' ? null : '2025-12-31',
      'status': status,
      'type': index.isEven ? 'CLT' : 'PJ',
    };
    (position['allocations'] as List<Map<String, dynamic>>).add(allocation);
    collaborators.add({
      'personPublicId': personPublicId,
      'personName': 'Colaborador ${index + 1}',
      'status': status,
      'segments': [
        {
          'kind': 'allocation',
          'employmentLinkPublicId': employmentLinkPublicId,
          'contractPublicId': contractPublicId,
          'positionPublicId': position['publicId'],
          'startsAt': startsAt,
          'endsAt': status == 'active' ? null : '2025-12-31',
          'status': status,
        },
      ],
      'events': [],
    });
  }

  final events = [
    for (var index = 0; index < structuredMovesCount; index++)
      {
        'publicId': _id('mov', index),
        'eventType': 'move',
        'source': 'employment_move',
        'occurredAt':
            '2025-${((index % 12) + 1).toString().padLeft(2, '0')}-15',
        'personPublicId': _id('pes', index),
        'employmentLinkPublicId': _id('vin', index),
        'originPositionPublicId': _id('pos', index % positionsCount),
        'destinationPositionPublicId': _id('pos', (index + 1) % positionsCount),
        'label': 'Movimentacao ${index + 1}',
        'notes': null,
      },
  ];

  return {
    'data': {
      'period': {'preset': '2y', 'from': '2024-01-01', 'to': '2026-01-01'},
      'focus': {
        'companyPublicId': 'emp_root_001',
        'companyType': 'provider_company',
        'displayName': 'PariFlow Services',
      },
      'layers': {
        'contracts': contracts,
        'collaborators': collaborators,
        'events': events,
      },
      'currentSnapshot': {
        'contracts': [],
        'positions': [],
        'collaborators': [],
      },
      'legend': {'eventTypes': [], 'relationshipStates': []},
      'warnings': [],
    },
    'meta': {'traceId': 'req_target_volume_test'},
  };
}

String _id(String prefix, int index) {
  return '${prefix}_${index.toString().padLeft(4, '0')}';
}

const _fixtureJson = '''
{
  "data": {
    "period": {
      "preset": "1y",
      "from": "2025-05-16",
      "to": "2026-05-16"
    },
    "focus": {
      "companyPublicId": "emp_root_001",
      "companyType": "provider_company",
      "displayName": "PariFlow Services"
    },
    "layers": {
      "contracts": [
        {
          "publicId": "ctr_001",
          "providerCompanyPublicId": "emp_root_001",
          "providerCompanyName": "PariFlow Services",
          "clientCompanyPublicId": "cli_001",
          "clientCompanyName": "Acme Operacoes",
          "displayName": "PariFlow Services -> Acme Operacoes",
          "startsAt": "2025-01-01",
          "endsAt": null,
          "status": "active",
          "positions": [
            {
              "publicId": "pos_001",
              "contractPublicId": "ctr_001",
              "displayName": "Portaria 12x36",
              "serviceName": "Portaria",
              "location": "Unidade Campinas",
              "shift": "Noturno",
              "schedule": "12x36",
              "status": "active",
              "startsAt": "2025-01-01",
              "endsAt": null,
              "dateSource": "contract",
              "allocations": [
                {
                  "employmentLinkPublicId": "vin_001",
                  "personPublicId": "pes_001",
                  "personName": "Mariana Silva",
                  "providerCompanyPublicId": "emp_root_001",
                  "contractPublicId": "ctr_001",
                  "positionPublicId": "pos_001",
                  "startsAt": "2025-02-01",
                  "endsAt": null,
                  "status": "active",
                  "type": "CLT"
                }
              ]
            }
          ]
        }
      ],
      "collaborators": [
        {
          "personPublicId": "pes_001",
          "personName": "Mariana Silva",
          "status": "active",
          "segments": [
            {
              "kind": "allocation",
              "employmentLinkPublicId": "vin_001",
              "contractPublicId": "ctr_001",
              "positionPublicId": "pos_001",
              "startsAt": "2025-02-01",
              "endsAt": null,
              "status": "active"
            }
          ],
          "events": [
            {
              "publicId": "evt_adm_001",
              "eventType": "admission",
              "source": "employment_link",
              "occurredAt": "2025-02-01",
              "personPublicId": "pes_001",
              "employmentLinkPublicId": "vin_001",
              "positionPublicId": "pos_001",
              "label": "Admissao",
              "notes": null
            },
            {
              "publicId": "mov_001",
              "eventType": "move",
              "source": "employment_move",
              "occurredAt": "2025-08-01",
              "personPublicId": "pes_001",
              "employmentLinkPublicId": "vin_001",
              "originPositionPublicId": null,
              "destinationPositionPublicId": null,
              "originLabel": "Portaria 12x36",
              "destinationLabel": "Portaria Lider",
              "label": "Movimentacao registrada sem referencia estruturada",
              "notes": "Movimentacao historica possui origem/destino textual."
            }
          ]
        }
      ],
      "events": [
        {
          "publicId": "evt_adm_001",
          "eventType": "admission",
          "source": "employment_link",
          "occurredAt": "2025-02-01",
          "personPublicId": "pes_001",
          "employmentLinkPublicId": "vin_001",
          "positionPublicId": "pos_001",
          "label": "Admissao",
          "notes": null
        },
        {
          "publicId": "mov_001",
          "eventType": "move",
          "source": "employment_move",
          "occurredAt": "2025-08-01",
          "personPublicId": "pes_001",
          "employmentLinkPublicId": "vin_001",
          "originPositionPublicId": null,
          "destinationPositionPublicId": null,
          "originLabel": "Portaria 12x36",
          "destinationLabel": "Portaria Lider",
          "label": "Movimentacao registrada sem referencia estruturada",
          "notes": "Movimentacao historica possui origem/destino textual."
        }
      ]
    },
    "currentSnapshot": {
      "contracts": [
        {
          "publicId": "ctr_001",
          "displayName": "PariFlow Services -> Acme Operacoes",
          "status": "active",
          "activePositions": 1,
          "activeCollaborators": 1
        }
      ],
      "positions": [
        {
          "publicId": "pos_001",
          "contractPublicId": "ctr_001",
          "displayName": "Portaria 12x36",
          "status": "active",
          "activeCollaborators": 1
        }
      ],
      "collaborators": [
        {
          "personPublicId": "pes_001",
          "personName": "Mariana Silva",
          "employmentLinkPublicId": "vin_001",
          "contractPublicId": "ctr_001",
          "positionPublicId": "pos_001",
          "status": "active"
        }
      ]
    },
    "legend": {
      "eventTypes": [
        {"value": "admission", "label": "Admissao"},
        {"value": "move", "label": "Movimentacao"}
      ],
      "relationshipStates": [
        {"value": "active", "label": "Ativo"},
        {"value": "incomplete", "label": "Dado incompleto"}
      ]
    },
    "warnings": [
      {
        "code": "employment_move_unstructured",
        "severity": "warning",
        "entityPublicId": "mov_001",
        "message": "Movimentacao possui origem/destino textual sem referencia estruturada para posto."
      }
    ]
  },
  "meta": {
    "traceId": "req_network_timeline_test"
  }
}
''';
