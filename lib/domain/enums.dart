// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

enum AccountColor { RED, GREEN, BLUE, YELLOW, PURPLE, ORANGE, TEAL, GREY }

enum AccountIcon { BANK, WALLET, CARD, CASH, SAVINGS, INVEST, GIFT, OTHER }

enum AccountType {
  CASH,
  CREDIT_CARD,
  SAVINGS_ACCOUNT,
  CURRENT_ACCOUNT,
  GOAL,
  DEBT,
  LOAN,
  BUDGET,
}

extension AccountColorExt on AccountColor {
  Color get toColor {
    switch (this) {
      case AccountColor.RED:
        return const Color(0xFF4D1717);
      case AccountColor.GREEN:
        return Colors.green;
      case AccountColor.BLUE:
        return Colors.blue;
      case AccountColor.YELLOW:
        return Colors.amber;
      case AccountColor.PURPLE:
        return Colors.purple;
      case AccountColor.ORANGE:
        return Colors.orange;
      case AccountColor.TEAL:
        return Colors.teal;
      case AccountColor.GREY:
        return Colors.grey;
    }
  }
}

extension AccountIconExt on AccountIcon {
  IconData get toIconData {
    switch (this) {
      case AccountIcon.BANK:
        return Icons.account_balance;
      case AccountIcon.WALLET:
        return Icons.account_balance_wallet;
      case AccountIcon.CARD:
        return Icons.credit_card;
      case AccountIcon.CASH:
        return Icons.attach_money;
      case AccountIcon.SAVINGS:
        return Icons.savings;
      case AccountIcon.INVEST:
        return Icons.trending_up;
      case AccountIcon.GIFT:
        return Icons.card_giftcard;
      case AccountIcon.OTHER:
        return Icons.circle;
    }
  }
}

extension AccountTypeExt on AccountType {
  String get displayName {
    switch (this) {
      case AccountType.CASH:
        return 'Efectivo';
      case AccountType.CREDIT_CARD:
        return 'Tarjeta de Crédito';
      case AccountType.SAVINGS_ACCOUNT:
        return 'Cuenta de Ahorros';
      case AccountType.CURRENT_ACCOUNT:
        return 'Cuenta Corriente';
      case AccountType.GOAL:
        return 'Meta';
      case AccountType.DEBT:
        return 'Deuda';
      case AccountType.LOAN:
        return 'Préstamo';
      case AccountType.BUDGET:
        return 'Presupuesto';
    }
  }
}
