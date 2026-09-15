-- Portable balance-sheet schema for MySQL or SQLite.
-- Amounts are stored as positive values; account_type supplies the sign meaning.

CREATE TABLE accounts (
  account_id INTEGER PRIMARY KEY,
  account_name VARCHAR(100) NOT NULL UNIQUE,
  account_type VARCHAR(20) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  CHECK (account_type IN ('asset', 'liability'))
);

CREATE TABLE balance_sheet_dates (
  balance_date DATE PRIMARY KEY
);

CREATE TABLE account_balances (
  balance_date DATE NOT NULL,
  account_id INTEGER NOT NULL,
  amount DECIMAL(18,2) NOT NULL,

  PRIMARY KEY (balance_date, account_id),
  FOREIGN KEY (balance_date) REFERENCES balance_sheet_dates(balance_date),
  FOREIGN KEY (account_id) REFERENCES accounts(account_id),
  CHECK (amount >= 0)
);

CREATE INDEX idx_account_balances_account_date
  ON account_balances (account_id, balance_date);
