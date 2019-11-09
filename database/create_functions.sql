-- Called when backs function
-- Assume that relevant checks have already been completed
CREATE OR REPLACE FUNCTION backs (
    user_email varchar(255),
    project_backed_name varchar(255),
    reward_backed_name varchar(255),
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
        -- UPDATE Projects
        --     SET project_current_funding = (SELECT project_current_funding + backs_amount FROM Projects WHERE Projects.project_name=project_backed_name)
        --     WHERE Projects.project_name=project_backed_name;

        /* Insert new transactions */
        INSERT INTO Transactions (amount, transaction_date) VALUES
            (backs_amount::numeric(20,2), current_timestamp)
            RETURNING transaction_id INTO backs_transaction_id;
        
        /* Insert new backing funds */
        INSERT INTO BackingFunds (transaction_id, email, project_name, reward_name) VALUES
            (backs_transaction_id, user_email, project_backed_name, reward_backed_name);

        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END; $$
LANGUAGE PLPGSQL;

-- Called when backs function
-- Assume that relevant checks have already been completed
CREATE OR REPLACE FUNCTION backsNoReward (
    user_email varchar(255),
    project_backed_name varchar(255),
    backs_amount numeric) RETURNS boolean
AS $$
DECLARE
    backs_transaction_id integer DEFAULT 0;
    old_donated_amount numeric;
BEGIN
    SELECT amount INTO old_donated_amount FROM priorDonation(user_email, project_backed_name);
    RAISE NOTICE 'old donated amount is %', old_donated_amount;

    IF (hasDonated(user_email, project_backed_name)) THEN
        IF (backs_amount > old_donated_amount) THEN
            /* if new new amount is more, need to check if wallet has sufficient cash */
            IF (wallet_sufficient(user_email, backs_amount)) THEN
                RAISE NOTICE 'donated and has sufficient amount';
                /* Transfer from backer's wallet to project */
                UPDATE Wallets
                    SET amount = (SELECT amount - backs_amount + old_donated_amount
                                    FROM Wallets WHERE email=user_email)
                    WHERE
                        Wallets.email=user_email;

                /* Update donation */
                PERFORM updateDonation(user_email, project_backed_name, old_donated_amount, backs_amount);
                RETURN true;
            END IF;
        END IF;

        IF (backs_amount < old_donated_amount) THEN
            /* if new new amount is less, need to transfer money back to backer */
            /* Return difference back to user */
            RAISE NOTICE 'Returning %', (old_donated_amount - backs_amount);
            UPDATE Wallets
                SET amount = (SELECT amount + old_donated_amount - backs_amount
                               FROM Wallets WHERE email=user_email)
                WHERE
                    Wallets.email=user_email;

            /* Update donation */
             PERFORM updateDonation(user_email, project_backed_name, old_donated_amount, backs_amount);
            RETURN true;
        END IF;

    ELSE
        /* No prior donation made */
        IF (wallet_sufficient(user_email, backs_amount)) THEN
            RAISE NOTICE 'no donation made and has sufficient amount';

            /* Update reward (for donation) */
            UPDATE rewards SET reward_pledge_amount = backs_amount
                WHERE project_name = project_backed_name
                AND reward_name IS NULL;

            /* Transfer funds from backer to project */
            UPDATE Wallets
                SET amount = (SELECT amount - backs_amount
                             FROM Wallets WHERE email=user_email)
                WHERE Wallets.email=user_email;


            /* Insert new transaction with new donation amount. */
           INSERT INTO Transactions (amount, transaction_date) VALUES
                (backs_amount::numeric(20,2), current_timestamp)
                RETURNING transaction_id INTO backs_transaction_id;

            /* Insert new backing funds */
            INSERT INTO BackingFunds (transaction_id, email, project_name, reward_name) VALUES
                (backs_transaction_id, user_email, project_backed_name, null);

            RETURN true;
        END IF;
    END IF;

    RETURN false;
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION hasDonated(
    backerEmail varchar(255),
    projectName varchar(255)
) RETURNS boolean
AS $$
DECLARE
    has_donated boolean DEFAULT false;
BEGIN
    SELECT COUNT(*) > 0 INTO has_donated FROM priorDonation(backerEmail, projectName);
    RETURN has_donated;
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION priorDonation(
    backerEmail varchar(255),
    projectName varchar(255)
) RETURNS TABLE (transaction_id integer, amount numeric(20,2), backer_email varchar(255), project_name varchar(255))
AS $$
BEGIN
    RETURN QUERY
        SELECT T.transaction_id, T.amount, B.email, B.project_name FROM Transactions AS T
        NATURAL JOIN Backingfunds AS B
        WHERE
            B.reward_name IS NULL
            AND
            B.email = backerEmail
            AND
            B.project_name = projectName;
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION updateDonation(
    backerEmail varchar(255),
    projectName varchar(255),
    oldAmount numeric,
    newAmount numeric
) RETURNS boolean
AS $$
DECLARE
    new_transaction_id integer DEFAULT 0;
BEGIN
    /* Update reward (for donation) */
    UPDATE rewards
        SET reward_pledge_amount = newAmount
        WHERE project_name = projectName
        AND reward_name IS NULL;

    /* insert new transaction with negated amount from prior donation */
    INSERT INTO Transactions (amount, transaction_date) VALUES
        ((-oldAmount)::numeric(20,2), current_timestamp);

    /* insert new transaction with new donation amount */
    INSERT INTO Transactions (amount, transaction_date) VALUES
        (newAmount::numeric(20,2), current_timestamp)
        RETURNING transaction_id INTO new_transaction_id;

    /* update prior entry in backingfunds - transaction_id */
    UPDATE Backingfunds
        SET transaction_id = new_transaction_id
        WHERE
            Backingfunds.project_name = projectName
            AND
            Backingfunds.email = backerEmail
            AND
            Backingfunds.reward_name IS NULL;

    RETURN true;
END; $$
LANGUAGE PLPGSQL;

/* Ian's version of unback
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

        -- UPDATE Projects
        --     SET project_current_funding = (
        --         SELECT P.project_current_funding - T.amount
        --         FROM Transactions T
        --             NATURAL JOIN BackingFunds B
        --             JOIN projects P ON B.project_name = P.project_name 
        --         WHERE Projects.project_name=project_backed_name
        --         AND T.transaction_id = backed_transaction_id)
        --     WHERE Projects.project_name=project_backed_name;

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
*/

/*
    Raffles' version of unbacks function
*/
CREATE OR REPLACE FUNCTION unbacks (
    project_backed_name varchar(255),
    reward_backed_name varchar(255),
    user_email varchar(255)) RETURNS boolean
AS $$
DECLARE
    backed_transaction_id integer;
    transfer_back_transaction_id integer;
BEGIN
    /* Find previous transaction backing that is related to the project and reward intended to unback. */
    DROP TABLE IF EXISTS old_transaction_backing;

    IF (reward_backed_name IS NULL) THEN
        CREATE TEMP TABLE old_transaction_backing AS
        SELECT T.transaction_id, T.amount, B.email
            FROM transactions AS T, backingfunds AS B
            WHERE T.transaction_id = B.transaction_id
                AND B.email = user_email
                AND B.project_name = project_backed_name
                AND B.reward_name IS NULL;
    ELSE
        CREATE TEMP TABLE old_transaction_backing AS
        SELECT T.transaction_id, T.amount, B.email
            FROM transactions AS T, backingfunds AS B
            WHERE T.transaction_id = B.transaction_id
                AND B.email = user_email
                AND B.project_name = project_backed_name
                AND B.reward_name = reward_backed_name;
    END IF;

    /* Create new transaction */
    /* Handle transfer of credit from project back to user */
    UPDATE Wallets
        SET amount = (SELECT W.amount + OT.amount FROM Wallets W, old_transaction_backing AS OT
                        WHERE W.email = OT.email)
        WHERE Wallets.email=user_email;

    -- /* Reduce current funding displayed on Project */
    -- UPDATE Projects
    --     SET project_current_funding = (
    --         SELECT P.project_current_funding - OT.amount
    --         FROM projects AS P, old_transaction_backing AS OT
    --         WHERE P.project_name = project_backed_name)
    --     WHERE Projects.project_name = project_backed_name;

    /* Remove from BackingFunds */
    DELETE FROM BackingFunds
        WHERE transaction_id = (SELECT transaction_id FROM old_transaction_backing);

    /* Create new transaction for this unback action */
    INSERT INTO Transactions (amount, transaction_date) VALUES
        (((SELECT OT.amount FROM old_transaction_backing AS OT))::numeric(20,2), current_timestamp)
        RETURNING transaction_id into transfer_back_transaction_id;
    
    /* Create new transfer to represent transfer back to user */
    INSERT INTO TransferFunds (transaction_id, email_transferer, email_transfee) VALUES
        (transfer_back_transaction_id, null, user_email);
    RETURN true;

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

-- Procedure for registration
CREATE OR REPLACE PROCEDURE register (
    user_email varchar(255),
    full_name varchar(255),
    phone_number varchar(255),
    password_hash varchar(255)
) 
AS $$ BEGIN 
    INSERT INTO Users(email, full_name, phone_number, password_hash, user_created_timestamp, user_last_login_timestamp) VALUES (
        user_email,full_name,phone_number,password_hash, LOCALTIMESTAMP, LOCALTIMESTAMP);
    INSERT INTO Wallets(email,amount) VALUES (user_email,0);
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE PROCEDURE register (
    user_email varchar(255),
    full_name varchar(255),
    phone_number varchar(255),
    password_hash varchar(255),
    user_created_timestamp timestamp,
    user_last_login_timestamp timestamp
) 
AS $$ BEGIN 
    INSERT INTO Users(email, full_name, phone_number, password_hash, user_created_timestamp, user_last_login_timestamp) VALUES (
        user_email,full_name,phone_number,password_hash, user_created_timestamp, user_last_login_timestamp);
    INSERT INTO Wallets(email,amount) VALUES (user_email,0);
END; $$
LANGUAGE PLPGSQL;

-- Procedure for Search
CREATE OR REPLACE PROCEDURE search (
    user_email varchar(255),
    search_text varchar(255)
)
AS $$ BEGIN
    INSERT INTO SearchHistory(email,search_timestamp,search_text) VALUES (
        user_email,LOCALTIMESTAMP,search_text
    );
    INSERT INTO Searches(email,search_timestamp) VALUES (
        user_email,LOCALTIMESTAMP
    );

    END;
    $$
    LANGUAGE PLPGSQL;

-- Procedure for createFeedback
CREATE OR REPLACE PROCEDURE create_feedback (
    name_of_project_receiving_feedback varchar(255),
    feedback_value_text text,
    num_of_rating integer,
    feedbacker_email varchar(255))
AS $$ BEGIN
    INSERT INTO Feedbacks (project_name, feedback_text, rating_number, email) VALUES
    (name_of_project_receiving_feedback, feedback_value_text, num_of_rating, feedbacker_email);
END; $$
LANGUAGE PLPGSQL;

-- Function to get number of followers
CREATE OR REPLACE FUNCTION getAllFollowers()
    RETURNS TABLE(user_id varchar(255), followers bigint)
AS $$ BEGIN
    RETURN QUERY
     (SELECT T1.email, COUNT(DISTINCT follower_id) as followers from users T1 
LEFT Join follows T2 on T1.email = T2.following_id
GROUP BY T1.email);

END; $$
LANGUAGE PLPGSQL;

-- Function to get all the rewards backed by the backer on a project
CREATE OR REPLACE FUNCTION collectRefunds(
   backer_email VARCHAR(255),
   backed_project_name VARCHAR(255)
) RETURNS numeric
AS $$
DECLARE
    rec RECORD;
    current_amount numeric := 0;
    total_refund numeric := 0;
BEGIN
    FOR rec IN
        SELECT *
          FROM Transactions NATURAL JOIN BackingFunds
          WHERE email = backer_email AND project_name = backed_project_name
          ORDER BY reward_name ASC

    LOOP
        /* RAISE NOTICE 'Looping: %', rec.reward_name; */
        /* perform unback on each of them */
        /*total_refund := total_refund + rec.amount;*/
        PERFORM unbacks(rec.project_name, rec.reward_name, rec.email);
    END LOOP;

    return total_refund;
END;
$$ LANGUAGE plpgsql;

-- Function to get all the project funding status
CREATE OR REPLACE FUNCTION projectFundingStatus()
RETURNS TABLE (project_name varchar(255), email varchar(255), project_description text, project_image_url varchar(255), project_deadline timestamp, project_funding_goal integer,
ended boolean, project_funding_received integer, received_funding_after_deadline boolean, funding_received_after_deadline_is_valid boolean)
AS $$
BEGIN
    DROP TABLE IF EXISTS temporaryprojects;
    CREATE TEMP TABLE temporaryprojects AS (SELECT * FROM projectsStatusTemplate());

    UPDATE temporaryprojects
        SET
            ended = (deadline < current_timestamp),
            current_funding = project_current_funding(temporaryprojects.project_name),
            received_funding_after_deadline = transactionAfterDeadlineExist(temporaryprojects.project_name),
            funding_received_after_deadline_is_valid = transactionAfterDeadlineIsValid(temporaryprojects.project_name);

    RETURN QUERY SELECT * FROM temporaryprojects;
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION projectsStatusTemplate()
RETURNS TABLE (project_name varchar(255), email varchar(255), project_description text, project_image_url varchar(255), deadline timestamp,
funding_goal integer, ended boolean, current_funding integer, received_funding_after_deadline boolean, funding_received_after_deadline_is_valid boolean)
AS $$
BEGIN
    RETURN QUERY
        SELECT P.project_name, P.email, P.project_description, P.project_image_url, P.project_deadline,
                P.project_funding_goal, false AS ended, 0 AS current_funding, false AS received_funding_after_deadline,
                false AS funding_received_after_deadline_is_valid
            FROM Projects AS P;
END; $$
LANGUAGE PLPGSQL;

-- Function get all the funding status of projects created by the user
CREATE OR REPLACE FUNCTION projectsByUser(userEmail varchar(255))
RETURNS TABLE (project_name varchar(255), email varchar(255), project_description text, project_image_url varchar(255),
project_deadline timestamp, ended boolean, project_funding_goal integer, project_funding_received integer, received_funding_after_deadline boolean,
funding_received_after_deadline_is_valid boolean)
AS $$
BEGIN
    RETURN QUERY
        SELECT P.project_name, P.email, P.project_description, P.project_image_url, P.project_deadline,
            PJS.ended, PJS.project_funding_goal, PJS.project_funding_received, PJS.received_funding_after_deadline, PJS.funding_received_after_deadline_is_valid
        FROM projectfundingstatus() AS PJS NATURAL JOIN Projects AS P
        WHERE P.email = userEmail;
END; $$
LANGUAGE PLPGSQL;

-- Function get all the funding status of projects created by the user
CREATE OR REPLACE FUNCTION projectByName(projectName varchar(255))
RETURNS TABLE (project_name varchar(255), email varchar(255), project_description text, project_image_url varchar(255),
project_deadline timestamp, ended boolean, project_funding_goal integer, project_funding_received integer, received_funding_after_deadline boolean,
funding_received_after_deadline_is_valid boolean)
AS $$
BEGIN
    RETURN QUERY
        SELECT P.project_name, P.email, P.project_description, P.project_image_url, P.project_deadline,
            PJS.ended, PJS.project_funding_goal, PJS.project_funding_received, PJS.received_funding_after_deadline, PJS.funding_received_after_deadline_is_valid
        FROM projectfundingstatus() AS PJS NATURAL JOIN Projects AS P
        WHERE P.project_name = projectName;
END; $$
LANGUAGE PLPGSQL;

-- Function (for creator) to check if transaction after deadline for a spcific project exist
CREATE OR REPLACE FUNCTION transactionAfterDeadlineExist(projectName varchar(255))
RETURNS boolean
AS $$
DECLARE
    _count integer := 0;
BEGIN
    SELECT COUNT(*) INTO _count
    FROM (
        SELECT X.backer_email, P.email AS creator_email,
            X.project_name, X.amount, X.transaction_date, P.project_deadline
        FROM (
            SELECT B.email AS backer_email, T.transaction_id, T.transaction_date, B.project_name, T.amount
            FROM transactions AS T inner join backingfunds AS B ON (T.transaction_id = B.transaction_id)) AS X
                INNER JOIN Projects AS P ON (X.project_name = P.project_name)
                WHERE X.project_name = projectName AND X.transaction_date > P.project_deadline) AS Z;

    IF (_count > 0) THEN
        RETURN true;
    ELSE
        RETURN false;
    END IF;
END; $$
LANGUAGE PLPGSQL;

-- Function (for creator) to check if transaction after deadline is equal to total fundings before deadline
-- Pre-cond: after deadline transaction must have amount that is equal to total of funding amounts right before deadline.
--              creator email and backer email must be the same.
--              transaction date must be after project deadline
CREATE OR REPLACE FUNCTION transactionAfterDeadlineIsValid(projectName varchar(255))
RETURNS boolean
AS $$
DECLARE
    _count integer := 0;
BEGIN
    SELECT COUNT(*) INTO _count FROM (
        SELECT X.backer_email, P.email AS creator_email,
            X.project_name, X.amount, X.transaction_date, P.project_deadline
        FROM (
            SELECT B.email AS backer_email, T.transaction_id, T.transaction_date, B.project_name, T.amount
            FROM transactions AS T inner join backingfunds AS B ON (T.transaction_id = B.transaction_id)) AS X
                INNER JOIN Projects AS P ON (X.project_name = P.project_name)
                WHERE X.project_name = projectName
                    AND X.transaction_date > P.project_deadline
                    AND X.amount = project_current_funding(X.project_name)
                    AND P.email = X.backer_email
    ) AS XX;

    IF (_count > 0) THEN
        RETURN true;
    ELSE
        RETURN false;
    END IF;
END; $$
LANGUAGE PLPGSQL;

-- Function transfer funds from holding area (by GoGuru) to Creator.
CREATE OR REPLACE FUNCTION transferBackingFundsToCreator(
    creatorEmail varchar(255),
    projectName varchar(255))
RETURNS boolean
AS $$
DECLARE
    _is_creator boolean := false;
    _total_funding integer := 0;
    _latest_transaction_id integer DEFAULT 0;

BEGIN
    -- Is creator?
    SELECT (COUNT(*) > 0) INTO _is_creator FROM Projects WHERE project_name = projectName AND email = creatorEmail;
    -- Is fully funded?
    -- Has not collect funds yet?

    SELECT * INTO _total_funding FROM project_current_funding(projectName);

    IF (_is_creator = false) THEN
        RAISE NOTICE 'IS NOT CREATOR';
        RETURN false;
    ELSE
        RAISE NOTICE 'IS CREATOR';
        RAISE NOTICE 'FUNDING IS: %', _total_funding;
        -- create new transaction with new amount, note the transaction id
        INSERT INTO Transactions (amount, transaction_date) VALUES
            (_total_funding::numeric(20,2), current_timestamp)
            RETURNING transaction_id INTO _latest_transaction_id;

        -- Insert new backing funds
        INSERT INTO TransferFunds (transaction_id, email_transferer, email_transfee) VALUES
            (_latest_transaction_id, null, creatorEmail);

        -- Update creator wallet
        UPDATE Wallets SET amount = (amount + _total_funding) WHERE email = creatorEmail;

        -- Update redeem
        INSERT INTO Redeem (project_name, email) VALUES
            (projectName, creatorEmail);

        RETURN true;
    END IF;
END; $$
LANGUAGE PLPGSQL;
