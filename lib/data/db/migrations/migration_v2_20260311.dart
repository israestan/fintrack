import 'package:sqflite/sqflite.dart';

/// Migración v1 → v2 (2026-03-11)
///
/// Reemplaza `budget_accounts` (presupuesto vinculado a cuentas) por
/// `budget_categories` (presupuesto vinculado a categorías), que refleja
/// correctamente la semántica: un presupuesto monitoriza el gasto OUTCOME
/// de una categoría, sin importar la cuenta desde la que se realice.
Future<void> migrateV1toV2(Database db) async {
  await db.execute('DROP TABLE IF EXISTS budget_accounts');
  await db.execute('''
CREATE TABLE budget_categories (
  budget_id   TEXT NOT NULL REFERENCES budget(id) ON DELETE CASCADE,
  category_id TEXT NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  created_at  TEXT NULL,
  updated_at  TEXT NULL,
  PRIMARY KEY (budget_id, category_id)
)
''');
}
