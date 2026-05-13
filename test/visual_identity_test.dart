import 'package:flutter_test/flutter_test.dart';
import 'package:pariflow_partners/shared/models/visual_identity.dart';

void main() {
  test('generates stable company identities', () {
    final first = VisualIdentityGenerator.forEntity(
      entityType: VisualEntityType.company,
      entityId: 'company-001',
      displayName: 'PariFlow',
    );
    final second = VisualIdentityGenerator.forEntity(
      entityType: VisualEntityType.company,
      entityId: 'company-001',
      displayName: 'PariFlow',
    );

    expect(second.shape, first.shape);
    expect(second.primaryColor, first.primaryColor);
    expect(second.pattern, first.pattern);
    expect(first.shape, VisualShape.hexagon);
  });

  test('keeps identity stable when display name changes', () {
    final beforeRename = VisualIdentityGenerator.forEntity(
      entityType: VisualEntityType.company,
      entityId: 'company-001',
      displayName: 'PariFlow',
    );
    final afterRename = VisualIdentityGenerator.forEntity(
      entityType: VisualEntityType.company,
      entityId: 'company-001',
      displayName: 'PariFlow Partners',
    );

    expect(afterRename, beforeRename);
  });

  test('uses different shapes by entity type', () {
    expect(
      VisualIdentityGenerator.forEntity(
        entityType: VisualEntityType.client,
        entityId: 'client-001',
      ).shape,
      VisualShape.pentagon,
    );
    expect(
      VisualIdentityGenerator.forEntity(
        entityType: VisualEntityType.contract,
        entityId: 'contract-001',
      ).shape,
      VisualShape.flatDiamond,
    );
    expect(
      VisualIdentityGenerator.forEntity(
        entityType: VisualEntityType.position,
        entityId: 'position-001',
      ).shape,
      VisualShape.square,
    );
  });

  test('category identities carry at least three colors', () {
    final identity = VisualIdentityGenerator.forEntity(
      entityType: VisualEntityType.category,
      entityId: 'category-001',
    );

    expect(identity.shape, VisualShape.circle);
    expect(identity.pattern, VisualPattern.organicBlobs);
    expect({identity.primaryColor, ...identity.secondaryColors}, hasLength(3));
  });
}
