import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../view_models/movements_view_model.dart';
import '../../view_models/categories_view_model.dart';
import '../../view_models/accounts_view_model.dart';
import '../../domain/models/movement.dart';
import '../../domain/enums.dart';

import '../create_movement_screen.dart';
import '../../widgets/movement_details.dart';

class MovementsTab extends StatefulWidget {
  const MovementsTab({super.key});

  @override
  State<MovementsTab> createState() => _MovementsTabState();
}

class _MovementsTabState extends State<MovementsTab> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       Provider.of<MovementsViewModel>(context, listen: false).loadMovements();
    });
  }

  // Helper to group movements by date (Day)
  Map<String, List<Movement>> _groupMovementsByDate(List<Movement> movements) {
    final Map<String, List<Movement>> groups = {};
    for (var m in movements) {
      final date = DateTime.parse(m.date);
      // Format: "domingo, 5 de noviembre, 2023"
      String key = DateFormat('EEEE, d \'de\' MMMM, y', 'es').format(date);
      // Capitalize first letter
      key = key[0].toUpperCase() + key.substring(1);
      
      if (groups.containsKey(key)) {
        groups[key]!.add(m);
      } else {
        groups[key] = [m];
      }
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    // Definir altura consistente para Headers
    const double headerHeight = 60.0;
    final Color headerColor = Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Colors.white;

    return Column(
      children: [
        // Header Consistente que cubre el StatusBar
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: headerColor,
            border: Border(
              bottom: BorderSide(
                color: Colors.black.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Container(
              height: headerHeight,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Movimientos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {}, // Placeholder
                      ),
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {}, // Placeholder
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // New Movement Button (As requested: "Después del título pero antes de los filtros")
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateMovementScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Nuevo movimiento'),
               style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),

        // Filters Placeholder
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildFilterChip('Cuenta'),
              const SizedBox(width: 8),
              _buildFilterChip('Tipo'),
              const SizedBox(width: 8),
              _buildFilterChip('Periodo'),
            ],
          ),
        ),

        // List
        Expanded(
          child: Consumer3<MovementsViewModel, CategoriesViewModel, AccountsViewModel>(
            builder: (context, movementsVm, categoriesVm, accountsVm, child) {
              if (movementsVm.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (movementsVm.error != null) {
                return Center(child: Text('Error: ${movementsVm.error}'));
              }

              final movements = movementsVm.movements;
              if (movements.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay movimientos aún',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              // Group movements
              final grouped = _groupMovementsByDate(movements);
              final groupKeys = grouped.keys.toList();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: groupKeys.length,
                itemBuilder: (context, index) {
                  final dateKey = groupKeys[index];
                  final daysMovements = grouped[dateKey]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Text(
                          dateKey,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            for (var i = 0; i < daysMovements.length; i++) ...[
                              if (i > 0)
                                Divider(
                                  height: 1,
                                  indent: 64,
                                  color: Colors.grey.withValues(alpha: 0.2),
                                ),
                              _buildMovementTile(
                                context,
                                daysMovements[i],
                                categoriesVm,
                                accountsVm,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, size: 16),
        ],
      ),
    );
  }

  Widget _buildMovementTile(
    BuildContext context,
    Movement movement,
    CategoriesViewModel catVm,
    AccountsViewModel accVm,
  ) {
    // Resolve Category Icon
    IconData iconData = Icons.help_outline;
    Color iconColor = Colors.grey;
    Color iconBg = Colors.grey.shade100;
    String title = 'Movimiento';

    // If category exists, use category data
    if (movement.categoryId != null) {
      final cat = catVm.getCategoryById(movement.categoryId!);
      if (cat != null) {
        title = cat.name;
        try {
            final accIcon = AccountIcon.values.firstWhere((e) => e.name == cat.icon);
            iconData = accIcon.toIconData;
        } catch (_) {}
        
        try {
             final accColor = AccountColor.values.firstWhere((e) => e.name == cat.color);
             iconColor = accColor.toColor;
             iconBg = iconColor.withValues(alpha: 0.1);
        } catch (_) {}
      }
    } else {
      // Default icon based on type if no category
      if (movement.type == 'INCOME') {
        iconData = Icons.attach_money;
        iconColor = Colors.green;
        iconBg = Colors.green.shade50;
      } else {
        iconData = Icons.money_off;
        iconColor = Colors.red;
        iconBg = Colors.red.shade50;
      }
    }

    // Account Name
    String accountName = 'Unknown Account';
    final acc = accVm.accounts.firstWhere(
        (a) => a.id == movement.accountId, 
        orElse: () => accVm.accounts.isNotEmpty ? accVm.accounts.first : accVm.accounts.first // Safety fallback
    );
    // Ideally getAccountById in VM would be better but list is small
    // We can iterate straightforwardly since we provided accountsVm
    try {
        final found = accVm.accounts.firstWhere((a) => a.id == movement.accountId);
        accountName = found.name;
    } catch (_) {}


    final isIncome = movement.type == 'INCOME';
    final amountSymbol = isIncome ? '+' : '-';
    final amountColor = isIncome ? Colors.green.shade700 : Colors.red.shade700;
    
    final formattedAmount = NumberFormat.currency(symbol: '\$', decimalDigits: 2)
        .format(movement.amountCents / 100.0);

    return ListTile(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => MovementDetails(
            movement: movement,
            categoryName: title,
            accountName: accountName,
            iconData: iconData,
            iconColor: iconColor,
          ),
        );
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: iconBg,
        child: Icon(iconData, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(
        accountName,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
      trailing: Text(
        '$amountSymbol$formattedAmount',
        style: TextStyle(
          color: amountColor,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}
