-- Totals and net worth for every recorded balance-sheet date.

SELECT b.`date`,
  SUM(CASE WHEN a.account_type = 'asset' THEN b.amount ELSE 0 END) AS total_assets,
  SUM(CASE WHEN a.account_type = 'liability' THEN b.amount ELSE 0 END) AS total_liabilities,
  SUM(CASE WHEN a.account_type = 'asset' THEN b.amount WHEN a.account_type = 'liability' THEN -b.amount END) AS net_worth
FROM balances AS b
INNER JOIN accounts AS a
  ON a.account_id = b.account_id
GROUP BY b.`date`
ORDER BY b.`date`;

-- All configured account values for a single balance-sheet date.
-- Bind the date in your application in place of the ? placeholder.
SELECT a.account_name,
  a.account_type,
  COALESCE(b.amount, 0) AS amount
FROM accounts AS a
LEFT JOIN balances AS b
  ON b.account_id = a.account_id
 AND b.`date` = ?
WHERE a.is_active = TRUE
ORDER BY a.account_type,
  a.account_name;

-- Monthly pivot with one column per configured account. Column names are
-- prefixed with asset_ or liability_ to keep the generated names distinct.
-- If a month has multiple snapshots, this returns the most recent one.
SET SESSION group_concat_max_len = 65535;

SELECT GROUP_CONCAT(
  CONCAT(
    'SUM(CASE WHEN b.account_id = ', a.account_id,
    ' THEN b.amount ELSE 0 END) AS `',
    REPLACE(CONCAT(a.account_type, '_', a.account_name), '`', '``'),
    '`'
  )
  ORDER BY a.account_type, a.account_name
  SEPARATOR ',\n      '
) INTO @account_columns
FROM accounts AS a;

SET @monthly_balance_sql = CONCAT(
  'SELECT\n',
  '  monthly.*,\n',
  '  monthly.total - LAG(monthly.total) OVER (ORDER BY monthly.`date`) ',
  'AS change_from_previous_date\n',
  'FROM (\n',
  '  SELECT\n',
  '    b.`date`,\n',
  '    ', @account_columns, ',\n',
  '    SUM(CASE\n',
  "          WHEN a.account_type = 'asset' THEN b.amount\n",
  "          WHEN a.account_type = 'liability' THEN -b.amount\n",
  '        END) AS total\n',
  '  FROM balances AS b\n',
  '  INNER JOIN (\n',
  '    SELECT MAX(`date`) AS `date`\n',
  '    FROM balances\n',
  '    GROUP BY EXTRACT(YEAR_MONTH FROM `date`)\n',
  '  ) AS latest_month ON latest_month.`date` = b.`date`\n',
  '  INNER JOIN accounts AS a\n'
  '    ON a.account_id = b.account_id\n',
  '  GROUP BY b.`date`\n',
  ') AS monthly\n',
  'ORDER BY monthly.`date`'
);

PREPARE monthly_balance_statement FROM @monthly_balance_sql;
EXECUTE monthly_balance_statement;
DEALLOCATE PREPARE monthly_balance_statement;
