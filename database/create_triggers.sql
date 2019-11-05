CREATE OR REPLACE FUNCTION check_create_project () RETURNS trigger
AS $$ BEGIN
    IF created_project_more_than_n_days(NEW.email, 3) THEN
        RAISE EXCEPTION 'User % created project in last 3 days.', NEW.email; 
    END IF;

    IF has_not_logged_in_past_n_days(NEW.email, 10) THEN
        RAISE EXCEPTION 'User % has not logged in past 10 days.', NEW.email;
    END IF;

    IF has_not_created_in_past_n_days(NEW.email, 30) THEN
        RAISE EXCEPTION 'User % had just been created in past 30 days.', NEW.email;
    END IF;

    RETURN NEW;
END; $$
LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS check_create_project ON Projects;
CREATE TRIGGER check_create_project BEFORE INSERT ON Projects
    FOR EACH ROW EXECUTE PROCEDURE check_create_project();

CREATE OR REPLACE FUNCTION created_project_more_than_n_days (
    varchar(255), integer) RETURNS boolean
AS $$
DECLARE
    _var integer;
BEGIN
    EXECUTE format('SELECT 1 FROM Projects P
        NATURAL JOIN Users U
        WHERE   P.email = ''%s''
        AND     (LOCALTIMESTAMP - project_created_timestamp) <= interval ''%s days'';', $1, $2)
    INTO _var;
    IF _var THEN
        RETURN true;
    ELSE
        RETURN false;
    END IF;
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION has_not_logged_in_past_n_days(
    varchar(255), integer) RETURNS boolean
AS $$
DECLARE
    _var integer;
BEGIN
    EXECUTE format('SELECT 1 FROM Users U
        WHERE   U.email = ''%s''
        AND     (LOCALTIMESTAMP - user_last_login_timestamp) > interval ''%s days'';', $1, $2)
    INTO _var;

    IF _var THEN
        RETURN true;
    ELSE
        RETURN false;
    END IF;
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION has_not_created_in_past_n_days(
    varchar(255), integer) RETURNS boolean
AS $$
DECLARE
    _var integer;
BEGIN
    EXECUTE format('SELECT 1 FROM Users U
        WHERE   U.email = ''%s''
        AND     (LOCALTIMESTAMP - U.user_created_timestamp) <= interval ''%s days'';', $1, $2)
    INTO _var;

    IF _var THEN
        RETURN true;
    ELSE
        RETURN false;
    END IF;
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION check_backing () RETURNS TRIGGER
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Projects P WHERE NEW.email = P.email AND NEW.project_name = P.project_name) THEN
        RAISE EXCEPTION 'User % cannot back own project %', NEW.email, NEW.project_name;
    END IF;

    IF EXISTS (SELECT 1 FROM Projects P WHERE NEW.project_name = P.project_name AND LOCALTIMESTAMP >= P.project_deadline) THEN
        RAISE EXCEPTION 'Cannot back a project that is past its deadline.';
    END IF;

    IF EXISTS (SELECT 1 FROM Transactions T WHERE NEW.transaction_id = T.transaction_id AND T.amount < 0) THEN
        RAISE EXCEPTION 'Cannot back a project with < $0.';
    END IF;

    IF (SELECT NOT wallet_sufficient(NEW.email, T.amount) FROM Transactions T WHERE New.transaction_id = T.transaction_id) THEN
        RAISE EXCEPTION 'Insufficient money in wallet for %.', NEW.email;
    END IF;

    RETURN NEW;

END; $$
LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS check_create_backingfund ON BackingFunds;
CREATE TRIGGER  check_create_backingfund BEFORE INSERT ON BackingFunds
    FOR EACH ROW EXECUTE PROCEDURE checK_backing();

/* Test cases for Trigger */
DROP IF EXISTS FROM Transactions WHERE transaction_id=1;
DROP IF EXISTS FROM Transactions WHERE transaction_id=2;
DROP IF EXISTS FROM Transactions WHERE transaction_id=3;

INSERT INTO Transactions VALUES (1, 1, LOCALTIMESTAMP);
INSERT INTO Transactions VALUES (2, -1, LOCALTIMESTAMP);
INSERT INTO Transactions VALUES (3, 1000, LOCALTIMESTAMP);

INSERT INTO BackingFunds VALUES (1, 'abi@example.com', 'Project 1', null);
INSERT INTO BackingFunds VALUES (1, 'abi@example.com', 'Project 3', null);
INSERT INTO BackingFunds VALUES (2, 'abi@example.com', 'Project 2', null);
INSERT INTO BackingFunds VALUES (3, 'abi@example.com', 'Project 2', null);