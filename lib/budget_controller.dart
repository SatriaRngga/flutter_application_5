import 'package:get/get.dart';

class Budget {
  final String name;
  final double amount;
  final bool isExpense;

  Budget(this.name, this.amount, {this.isExpense = false});
}

class BudgetController extends GetxController {
  final _budgets = <Budget>[].obs;

  List<Budget> get budgets => _budgets;

  double get totalIncome =>
      _budgets.where((b) => !b.isExpense).fold(0.0, (sum, b) => sum + b.amount);

  double get totalExpenses =>
      _budgets.where((b) => b.isExpense).fold(0.0, (sum, b) => sum + b.amount);

  void addBudget(String name, double amount, {bool isExpense = false}) {
    _budgets.add(Budget(name, amount, isExpense: isExpense));
  }
}
