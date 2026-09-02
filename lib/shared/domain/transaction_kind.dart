/// Distinguishes income from expenses across categories and transactions.
///
/// Income and expenses live in separate tables (per Phase 0 schema); this enum
/// lets a single repository/UI path serve both by selecting the right table.
enum TransactionKind {
  income,
  expense;

  String get categoryTable => switch (this) {
    TransactionKind.income => 'income_categories',
    TransactionKind.expense => 'expense_categories',
  };

  String get transactionTable => switch (this) {
    TransactionKind.income => 'income_transactions',
    TransactionKind.expense => 'expense_transactions',
  };

  String get label => switch (this) {
    TransactionKind.income => 'Income',
    TransactionKind.expense => 'Expense',
  };
}
