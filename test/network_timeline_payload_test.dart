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
}

Map<String, dynamic> _fixtureMap() {
  return (jsonDecode(_fixtureJson) as Map).cast<String, dynamic>();
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
