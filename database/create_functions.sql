-- Called when backs function
-- Assume that relevant checks have already been completed
CREATE OR REPLACE FUNCTION backs (
    user_email varchar(255),
    project_backed_name varchar(255),
    backs_amount numeric) RETURNS boolean
AS $$
DECLARE
    backs_transaction_id integer DEFAULT 0;
BEGIN
    IF (wallet_sufficient(user_email, backs_amount)) THEN
        /* Handle transfer of credit */
        UPDATE Wallets
            SET amount = (SELECT amount - backs_amount FROM Wallets WHERE email=user_email) 
            WHERE Wallets.email=user_email;
        UPDATE Projects
            SET project_current_funding = (SELECT project_current_funding + backs_amount FROM Projects WHERE Projects.project_name=project_backed_name)
            WHERE Projects.project_name=project_backed_name;

        /* Insert new transactions */
        INSERT INTO Transactions (amount, transaction_date) VALUES
            (backs_amount::numeric(20,2), current_timestamp)
            RETURNING transaction_id INTO backs_transaction_id;
        
        /* Insert new backing funds */
        INSERT INTO BackingFunds (transaction_id, email, project_name) VALUES
            (backs_transaction_id, user_email, project_backed_name);

        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION unbacks (
    project_backed_name varchar(255),
    user_email varchar(255),
    backed_transaction_id integer) RETURNS boolean
AS $$
BEGIN
    /* Create new transaction */
    IF (transaction_exists(backed_transaction_id)) THEN
        /* Handle transfer of credit from project back to user */
        UPDATE Wallets
            SET amount = (SELECT W.amount + T.amount FROM Wallets W, Transactions T
                WHERE W.email=user_email
                AND T.transaction_id = backed_transaction_id)
            WHERE Wallets.email=user_email;

        UPDATE Projects
            SET project_current_funding = (
                SELECT P.project_current_funding - T.amount
                FROM Transactions T
                    NATURAL JOIN BackingFunds B
                    JOIN projects P ON B.project_name = P.project_name 
                WHERE Projects.project_name=project_backed_name
                AND T.transaction_id = backed_transaction_id)
            WHERE Projects.project_name=project_backed_name;

        /* Remove from BackingFunds */
        DELETE FROM BackingFunds
            WHERE transaction_id = backed_transaction_id;

        INSERT INTO Transactions (amount, transaction_date) VALUES
            (((SELECT -T.amount FROM Transactions T WHERE T.transaction_id = backed_transaction_id))::numeric(20,2), current_timestamp);
        RETURN true;
    ELSE
        RETURN false;
    END IF;
    /* No need to insert into backingfunds */

END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION transaction_exists (
    backs_transaction_id integer) RETURNS boolean
AS $$
BEGIN
    IF (EXISTS (SELECT 1 FROM Transactions T NATURAL JOIN BackingFunds B WHERE T.transaction_id = backs_transaction_id)) THEN
        RETURN true;
    ELSE
        RETURN false;
    END IF;
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE PROCEDURE topup_wallet (
    user_email varchar(255),
    new_wallet_amount numeric,
    topup_amount numeric
)
LANGUAGE PLPGSQL
AS $$
    DECLARE
        variable integer;
    BEGIN
        UPDATE Wallets SET amount = new_wallet_amount
            WHERE email = user_email;

        INSERT INTO Transactions (transaction_id, amount, transaction_date)
            VALUES (DEFAULT, topup_amount, LOCALTIMESTAMP)
            RETURNING transaction_id INTO variable;

        INSERT INTO TopUpFunds (transaction_id, email) VALUES
            (variable, user_email);
    END
$$;

CREATE OR REPLACE PROCEDURE transfer_from_wallet (
    sender_email varchar(255),
    receiver_email varchar(255),
    transfer_amount numeric
)
LANGUAGE PLPGSQL
AS $$
    DECLARE
        transactionId integer;
    BEGIN
        UPDATE Wallets SET amount = amount - transfer_amount
            WHERE email = sender_email;

        UPDATE Wallets SET amount = amount + transfer_amount
            WHERE email = receiver_email;

        INSERT INTO Transactions (transaction_id, amount, transaction_date)
            VALUES (DEFAULT, transfer_amount, LOCALTIMESTAMP)
            RETURNING transaction_id INTO transactionId;

        INSERT INTO TransferFunds (transaction_id, email_transferer, email_transfee) VALUES
            (transactionId, sender_email, receiver_email);
    END
$$;

-- Helper function to check if wallet has sufficient value
CREATE OR REPLACE FUNCTION wallet_sufficient (
    user_email varchar(255),
    amount_to_be_deducted numeric) RETURNS boolean
AS $$ BEGIN
    IF (SELECT Wallets.amount FROM Wallets WHERE email=user_email) >= amount_to_be_deducted THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END; $$
LANGUAGE PLPGSQL;

-- Function for registration
CREATE OR REPLACE PROCEDURE register (
    user_email varchar(255),
    full_name varchar(255),
    phone_number varchar(255),
    password_hash varchar(255)
) 
AS $$ BEGIN 
    INSERT INTO Users(email, full_name, phone_number, password_hash) VALUES (
        user_email,full_name,phone_number,password_hash
        );
    INSERT INTO Wallets(email,amount) VALUES (user_email,0);
    END;
    $$
    LANGUAGE PLPGSQL;


