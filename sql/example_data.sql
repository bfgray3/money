-- Example configurable accounts and one dated balance-sheet snapshot.

INSERT INTO accounts (account_id, account_name, account_type)
VALUES
  (1, 'Cash', 'asset'),
  (2, 'Investments', 'asset'),
  (3, 'Mortgage', 'liability'),
  (4, 'Credit Card', 'liability');

INSERT INTO dates (`date`)
VALUES ('2026-09-14');

INSERT INTO balances (`date`, account_id, amount)
VALUES
  ('2026-09-14', 1, 12500.00),
  ('2026-09-14', 2, 85000.00),
  ('2026-09-14', 3, 210000.00),
  ('2026-09-14', 4, 1800.00);
