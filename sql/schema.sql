-- MySQL balance-sheet schema.
-- Amounts are stored as positive values; account_type supplies the sign meaning.

CREATE TABLE accounts (
  account_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  account_name VARCHAR(100) NOT NULL UNIQUE,
  account_type VARCHAR(20) NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (account_id),
  CONSTRAINT chk_accounts_type CHECK (account_type IN ('asset', 'liability')),
  CONSTRAINT chk_accounts_is_active CHECK (is_active IN (0, 1))
) ENGINE=InnoDB;

CREATE TABLE dates (
  `date` DATE NOT NULL,
  PRIMARY KEY (`date`)
) ENGINE=InnoDB;

CREATE TABLE balances (
  `date` DATE NOT NULL,
  account_id SMALLINT UNSIGNED NOT NULL,
  amount DECIMAL(18,2) NOT NULL,

  PRIMARY KEY (`date`, account_id),
  FOREIGN KEY (`date`) REFERENCES dates(`date`),
  FOREIGN KEY (account_id) REFERENCES accounts(account_id),
  CONSTRAINT chk_balances_amount CHECK (amount >= 0)
) ENGINE=InnoDB;

CREATE INDEX idx_balances_account_date
  ON balances (account_id, `date`);

-- Account type determines the sign interpretation of all historical balances,
-- so it must never change after an account is created.
DELIMITER //

CREATE TRIGGER prevent_account_type_change
BEFORE UPDATE ON accounts
FOR EACH ROW
BEGIN
  IF NEW.account_type != OLD.account_type THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'account_type is immutable';
  END IF;
END//

DELIMITER ;
