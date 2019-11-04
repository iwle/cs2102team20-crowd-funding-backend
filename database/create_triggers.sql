CREATE OR REPLACE FUNCTION check_create_project () RETURNS trigger
AS $$ BEGIN
    IF created_project_more_than_n_days(NEW.email, 3) THEN
        RAISE EXCEPTION 'User created project in last 3 days.'; 
    END IF;

    IF has_not_logged_in_past_n_days(NEW.email, 10) THEN
        RAISE EXCEPTION 'User has not logged in past 10 days.';
    END IF;

    IF has_not_created_in_past_n_days(NEW.email, 30) THEN
        RAISE EXCEPTION 'User has not been created in past 30 days.';
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
        AND     (LOCALTIMESTAMP - user_last_login_timestamp) <= interval ''%s days'';', $1, $2)
    INTO _var;

    IF _var THEN
        RETURN not true;
    ELSE
        RETURN not false;
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
        AND     (LOCALTIMESTAMP - user_created_timestamp) > interval ''%s days'';', $1, $2)
    INTO _var;

    IF _var THEN
        RETURN not true;
    ELSE
        RETURN not false;
    END IF;
END; $$
LANGUAGE PLPGSQL;
