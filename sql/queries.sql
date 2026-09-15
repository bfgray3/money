-- Totals and net worth for every recorded balance-sheet date.

SELECT
  b.balance_date,
  SUM(CASE WHEN a.account_type = 'asset' THEN b.amount ELSE 0 END) AS total_assets,
  SUM(CASE WHEN a.account_type = 'liability' THEN b.amount ELSE 0 END) AS total_liabilities,
  SUM(CASE
        WHEN a.account_type = 'asset' THEN b.amount
        WHEN a.account_type = 'liability' THEN -b.amount
      END) AS net_worth
FROM account_balances AS b
JOIN accounts AS a ON a.account_id = b.account_id
GROUP BY b.balance_date
ORDER BY b.balance_date;

-- All configured account values for a single balance-sheet date.
-- Bind the date in your application in place of the ? placeholder.
SELECT
  a.account_name,
  a.account_type,
  COALESCE(b.amount, 0) AS amount
FROM accounts AS a
LEFT JOIN account_balances AS b
  ON b.account_id = a.account_id
 AND b.balance_date = ?
WHERE a.is_active = TRUE
ORDER BY a.account_type, a.display_order, a.account_name;
