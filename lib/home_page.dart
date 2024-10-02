import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'budget_controller.dart';

class HomePage extends StatelessWidget {
  final Color primaryColor = Color(0xFF5C6BC0);
  final Color accentColor = Color(0xFF3949AB);
  final Color incomeColor = Color(0xFF66BB6A);
  final Color expenseColor = Color(0xFFEF5350);
  final Color backgroundColor = Color(0xFFF5F7FA);

  final BudgetController budgetController = Get.put(BudgetController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Obx(() {
        final totalIncome = budgetController.totalIncome;
        final totalExpenses = budgetController.totalExpenses;
        final total = totalIncome - totalExpenses;

        return CustomScrollView(
          slivers: [
            _buildAppBar(total),
            SliverToBoxAdapter(
                child: _buildSummaryCards(totalIncome, totalExpenses)),
            SliverToBoxAdapter(child: _buildRecentTransactionsHeader()),
            _buildTransactionsList(),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context),
        child: Icon(Icons.add),
        backgroundColor: accentColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppBar(double total) {
    return SliverAppBar(
      expandedHeight: 200.0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColor, accentColor],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Total Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                SizedBox(height: 8),
                Text(
                    'Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '').format(total)}',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(double income, double expenses) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
              child: _buildSummaryCard(
                  'Income', income, incomeColor, Icons.arrow_upward)),
          SizedBox(width: 16),
          Expanded(
              child: _buildSummaryCard(
                  'Expenses', expenses, expenseColor, Icons.arrow_downward)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, double amount, Color color, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                SizedBox(width: 8),
                Text(title,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            Text(
                'Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '').format(amount)}',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsHeader() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Text('Recent Transactions',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
    );
  }

  Widget _buildTransactionsList() {
    return Obx(() {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final budget = budgetController.budgets[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      budget.isExpense ? expenseColor : incomeColor,
                  child: Icon(budget.isExpense ? Icons.remove : Icons.add,
                      color: Colors.white),
                ),
                title: Text(budget.name,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(budget.isExpense ? 'Expense' : 'Income'),
                trailing: Text(
                    'Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '').format(budget.amount)}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: budget.isExpense ? expenseColor : incomeColor)),
              ),
            );
          },
          childCount: budgetController.budgets.length,
        ),
      );
    });
  }

  void _showAddBudgetDialog(BuildContext context) {
    String name = '';
    String amount = '';
    RxBool isExpense = false.obs;

    Get.dialog(
      AlertDialog(
        title: Text('Add Transaction'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                    labelText: 'Name', border: OutlineInputBorder()),
                onChanged: (value) => name = value,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                    labelText: 'Amount', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onChanged: (value) => amount = value,
              ),
              SizedBox(height: 16),
              Obx(() => SwitchListTile(
                    title: Text('Is Expense?'),
                    value: isExpense.value,
                    onChanged: (value) => isExpense.value = value,
                    activeColor: accentColor,
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(child: Text('Cancel'), onPressed: () => Get.back()),
          ElevatedButton(
            child: Text('Add'),
            style: ElevatedButton.styleFrom(
                backgroundColor: accentColor, foregroundColor: Colors.white),
            onPressed: () {
              if (name.isNotEmpty &&
                  amount.isNotEmpty &&
                  double.tryParse(amount) != null) {
                budgetController.addBudget(name, double.parse(amount),
                    isExpense: isExpense.value);
                Get.back();
              }
            },
          ),
        ],
      ),
    );
  }
}
