import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:provider/provider.dart";
import "../domain/models/budget.dart";
import "../domain/models/category.dart";
import "../domain/models/goal_entry.dart";
import "../domain/models/account.dart";
import "../domain/enums/enums.dart";
import "../view_models/budgets_view_model.dart";
import "../view_models/goals_view_model.dart";
import "../view_models/accounts_view_model.dart";
import "../widgets/create_budget_sheet.dart";
import "../widgets/create_goal_sheet.dart";
import "../theme/app_theme.dart";

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetsViewModel>().loadBudgets();
      context.read<GoalsViewModel>().loadGoals();
    });
  }

  String _formatCents(int cents) {
    return NumberFormat.currency(symbol: r"$", decimalDigits: 2)
        .format(cents / 100);
  }

  String _periodLabel(String period) {
    switch (period) {
      case "daily":
        return "Diario";
      case "weekly":
        return "Semanal";
      case "yearly":
        return "Anual";
      default:
        return "Mensual";
    }
  }

  Color _progressColor(double ratio) {
    if (ratio >= 1.0) return Colors.red;
    if (ratio >= 0.8) return Colors.orange;
    return Colors.green;
  }

  void _showCreateBudgetSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const CreateBudgetSheet(),
    );
  }

  void _showCreateGoalSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const CreateGoalSheet(),
    );
  }

  Future<void> _confirmDeleteBudget(Budget budget) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar presupuesto"),
        content: Text(
            "Deseas eliminar \"${budget.entity}\"? Esta accion no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      try {
        await context.read<BudgetsViewModel>().deleteBudget(budget.id);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Error al eliminar: $e")));
        }
      }
    }
  }

  Future<void> _confirmDeleteGoal(GoalEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar meta"),
        content: Text(
            "Deseas eliminar \"${entry.account.name}\"? El saldo ahorrado se perdera."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      try {
        await context.read<GoalsViewModel>().deleteGoal(entry.account.id);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      }
    }
  }

  Future<void> _closeGoal(GoalEntry entry) async {
    final allAccounts = context.read<AccountsViewModel>().accounts;
    final eligible = allAccounts
        .where((a) => a.typeId != "GOAL" && a.active == 1)
        .toList();

    final hasSavings = entry.account.actualBalanceCents > 0;

    if (hasSavings && eligible.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "No hay cuentas disponibles para recibir el saldo. Crea una cuenta primero.")),
      );
      return;
    }

    Account? selectedAccount = eligible.isNotEmpty ? eligible.first : null;
    bool confirmed = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text("Cerrar meta"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("La meta \"${entry.account.name}\" sera marcada como completada."),
              if (hasSavings && eligible.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  "Se transferiran ${NumberFormat.currency(symbol: r"$", decimalDigits: 2).format(entry.account.actualBalanceCents / 100)} a:",
                  style: const TextStyle(fontSize: AppFontSizes.subtitle),
                ),
                const SizedBox(height: 8),
                DropdownButton<Account>(
                  value: selectedAccount,
                  isExpanded: true,
                  items: eligible
                      .map((a) => DropdownMenuItem(
                            value: a,
                            child: Text(a.name),
                          ))
                      .toList(),
                  onChanged: (a) =>
                      setDialogState(() => selectedAccount = a),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                confirmed = true;
                Navigator.pop(ctx);
              },
              child: const Text("Cerrar meta"),
            ),
          ],
        ),
      ),
    );

    if (!confirmed || !mounted) return;

    try {
      await context.read<GoalsViewModel>().closeGoal(
            goalAccountId: entry.account.id,
            targetAccountId: selectedAccount?.id ?? "",
            amountCents: entry.account.actualBalanceCents,
          );
      // Recargar cuentas ya que los saldos cambiaron
      if (mounted) context.read<AccountsViewModel>().loadAccounts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Meta cerrada exitosamente.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Widget _buildSectionHeader(String title, VoidCallback onAdd) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: AppFontSizes.headline,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 16),
          label: const Text("Nuevo"),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Planificacion"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  Presupuestos 
            _buildSectionHeader("Presupuestos", _showCreateBudgetSheet),
            const SizedBox(height: 12),
            Consumer<BudgetsViewModel>(
              builder: (context, vm, _) {
                if (vm.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (vm.error != null) {
                  return Center(child: Text("Error: ${vm.error}"));
                }
                if (vm.budgets.isEmpty) {
                  return _EmptyState(
                    icon: Icons.savings_outlined,
                    message: "No tienes presupuestos registrados.",
                    onAdd: _showCreateBudgetSheet,
                    addLabel: "Crear mi primer presupuesto",
                  );
                }
                return Column(
                  children: vm.budgets.map((budget) {
                    final spentCents = vm.spentCentsFor(budget.id);
                    final limitCents = budget.limitCents;
                    final ratio = limitCents > 0
                        ? (spentCents / limitCents).clamp(0.0, 1.0)
                        : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _BudgetCard(
                        budget: budget,
                        spentCents: spentCents,
                        ratio: ratio,
                        progressColor: _progressColor(
                            spentCents / (limitCents > 0 ? limitCents : 1)),
                        categories: vm.categoriesFor(budget.id),
                        periodLabel: _periodLabel(budget.period),
                        formatCents: _formatCents,
                        onDelete: () => _confirmDeleteBudget(budget),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 32),

            //  Metas de Ahorro 
            _buildSectionHeader("Metas de Ahorro", _showCreateGoalSheet),
            const SizedBox(height: 12),
            Consumer<GoalsViewModel>(
              builder: (context, vm, _) {
                if (vm.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (vm.error != null) {
                  return Center(child: Text("Error: ${vm.error}"));
                }
                if (vm.goals.isEmpty) {
                  return _EmptyState(
                    icon: Icons.flag_outlined,
                    message: "No tienes metas de ahorro registradas.",
                    onAdd: _showCreateGoalSheet,
                    addLabel: "Crear mi primera meta",
                  );
                }
                return Column(
                  children: vm.goals.map((entry) {
                    final savedCents = entry.account.actualBalanceCents;
                    final targetCents = entry.goal.targetAmountCents;
                    final ratio = targetCents > 0
                        ? (savedCents / targetCents).clamp(0.0, 1.0)
                        : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GoalCard(
                        entry: entry,
                        savedCents: savedCents,
                        ratio: ratio,
                        progressColor: _progressColor(ratio),
                        formatCents: _formatCents,
                        onClose: () => _closeGoal(entry),
                        onDelete: () => _confirmDeleteGoal(entry),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

//  Widgets privados 

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback onAdd;
  final String addLabel;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.onAdd,
    required this.addLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(message,
              style: TextStyle(
                  fontSize: AppFontSizes.subtitle,
                  color: Colors.grey.shade500)),
          TextButton(onPressed: onAdd, child: Text(addLabel)),
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final int spentCents;
  final double ratio;
  final Color progressColor;
  final List<Category> categories;
  final String periodLabel;
  final String Function(int) formatCents;
  final VoidCallback onDelete;

  const _BudgetCard({
    required this.budget,
    required this.spentCents,
    required this.ratio,
    required this.progressColor,
    required this.categories,
    required this.periodLabel,
    required this.formatCents,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    budget.entity,
                    style: const TextStyle(
                      fontSize: AppFontSizes.headline,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    periodLabel,
                    style: const TextStyle(
                      fontSize: AppFontSizes.bodySmall,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: "Eliminar",
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            if (categories.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: categories
                    .map((cat) => Chip(
                          label: Text(cat.name,
                              style: const TextStyle(
                                  fontSize: AppFontSizes.bodySmall)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 0),
                          backgroundColor:
                              AppTheme.secondaryColor.withValues(alpha: 0.8),
                          side: BorderSide.none,
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${formatCents(spentCents)} gastado",
                  style: TextStyle(
                    fontSize: AppFontSizes.subtitle,
                    color: progressColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "de ${formatCents(budget.limitCents)}",
                  style: TextStyle(
                      fontSize: AppFontSizes.subtitle,
                      color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final GoalEntry entry;
  final int savedCents;
  final double ratio;
  final Color progressColor;
  final String Function(int) formatCents;
  final VoidCallback onClose;
  final VoidCallback onDelete;

  const _GoalCard({
    required this.entry,
    required this.savedCents,
    required this.ratio,
    required this.progressColor,
    required this.formatCents,
    required this.onClose,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    AccountColor accountColor = AccountColor.GREY;
    AccountIcon accountIcon = AccountIcon.SAVINGS;
    try {
      accountColor = AccountColor.values
          .firstWhere((e) => e.name == entry.account.color);
    } catch (_) {}
    try {
      accountIcon = AccountIcon.values
          .firstWhere((e) => e.name == entry.account.icon);
    } catch (_) {}

    final targetParsed = DateTime.tryParse(entry.goal.targetDate);
    final dateLabel = targetParsed != null
        ? "${targetParsed.day.toString().padLeft(2, "0")}/"
            "${targetParsed.month.toString().padLeft(2, "0")}/"
            "${targetParsed.year}"
        : entry.goal.targetDate;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado: icon, nombre, fecha, delete
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: accountColor.toColor.withValues(alpha: 0.2),
                  child: Icon(accountIcon.toIconData,
                      color: accountColor.toColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.account.name,
                        style: const TextStyle(
                          fontSize: AppFontSizes.headline,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        entry.goal.objective,
                        style: TextStyle(
                          fontSize: AppFontSizes.subtitle,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 20, color: Colors.red),
                      onPressed: onDelete,
                      tooltip: "Eliminar",
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Text(
                      dateLabel,
                      style: TextStyle(
                        fontSize: AppFontSizes.bodySmall,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Barra de progreso
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 6),

            // Monto ahorrado / objetivo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${formatCents(savedCents)} ahorrado",
                  style: TextStyle(
                    fontSize: AppFontSizes.subtitle,
                    color: progressColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "de ${formatCents(entry.goal.targetAmountCents)}",
                  style: TextStyle(
                      fontSize: AppFontSizes.subtitle,
                      color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Botón cerrar meta
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onClose,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text("Cerrar meta"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green.shade700,
                  side: BorderSide(color: Colors.green.shade700),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}