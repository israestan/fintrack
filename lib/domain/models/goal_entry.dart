import 'account.dart';
import 'goal_account.dart';

/// Combina una Account (tipo GOAL) con su GoalAccount asociado.
/// Permite pasar ambas entidades juntas desde el repositorio al ViewModel y la UI.
class GoalEntry {
  final Account account;
  final GoalAccount goal;

  const GoalEntry({required this.account, required this.goal});
}
