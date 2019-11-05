/* --- Creating Project --- */
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

/* --- Creating Feedback --- */
CREATE OR REPLACE FUNCTION check_create_feedback () RETURNS trigger
AS $$ BEGIN
    IF user_is_creator_of_project_receiving_feedback(NEW.project_name, NEW.email) THEN
        RAISE EXCEPTION 'Bad: Creator of project cannot give feedback on their own project.';
    ELSE
        RAISE NOTICE 'Good: Feedbacker is not creator of the project';
    END IF;

    RAISE NOTICE 'New.project_name = %', New.project_name;
    RAISE NOTICE 'New.email = %', New.email;

    IF user_has_backed_project(NEW.project_name, NEW.email) != true THEN
        RAISE EXCEPTION 'Bad: User has not backed the project';
    ELSE
        RAISE NOTICE 'Good: Feedbacker is has previously backed the project';
    END IF;

    IF project_backed_is_live(NEW.project_name) THEN
        RAISE EXCEPTION 'Bad: Project is still ongoing.';
    ELSE
        RAISE NOTICE 'Good: Project has ended';
    END IF;

    IF project_backed_is_fully_funded(New.project_name) != true THEN
        RAISE EXCEPTION 'Bad: Project is not successfully funded';
    ELSE
        RAISE NOTICE 'Good: Project is fully funded';
    END IF;

    RETURN NEW;
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION user_is_creator_of_project_receiving_feedback (
    varchar(255), varchar(255)) RETURNS boolean
AS $$
DECLARE
    _result_count integer;
BEGIN
    EXECUTE format('SELECT COUNT(P.project_name) FROM Projects AS P
        WHERE P.project_name = ''%s''
        AND P.email = ''%s'';', $1, $2)
        INTO _result_count;
    IF _result_count THEN
        RETURN true;
    ELSE
        RETURN false;
    END IF;
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION user_has_backed_project (
    varchar(255), varchar(255)) RETURNS boolean
AS $$
DECLARE
    _result_count integer;
BEGIN
    EXECUTE format('SELECT COUNT(*) FROM backingfunds ' ||
     'WHERE project_name = ''%s'' AND email = ''%s'';', $1, $2)
        INTO _result_count;
    IF _result_count > 0 THEN
        RETURN true;
    ELSE
        RETURN false;
    END IF;
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION project_backed_is_live (
    varchar(255)) RETURNS boolean
AS $$
DECLARE
    _is_live integer;
BEGIN
    EXECUTE format('SELECT COUNT(*) FROM Projects WHERE ' ||
     'project_deadline > NOW() AND project_name = ''%s'';', $1)
        INTO _is_live;
    IF _is_live THEN
        RETURN true;
    ELSE
        RETURN false;
    END IF;
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION project_backed_is_fully_funded (
    varchar(255)) RETURNS boolean
AS $$
DECLARE
    _project_funding_goal integer;
BEGIN
    EXECUTE format('SELECT project_funding_goal FROM Projects WHERE ' ||
     'project_name = ''%s'';', $1)
        INTO _project_funding_goal;

    IF project_current_funding($1) < _project_funding_goal THEN
        RETURN false;
    ELSE
        RETURN true;
    END IF;
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION project_current_funding (varchar(255)) RETURNS numeric
AS $$
DECLARE
    _current_funding numeric;
BEGIN
    EXECUTE format('SELECT SUM(T.amount) FROM Backingfunds AS B, Transactions AS T' ||
    ' WHERE T.transaction_id = B.transaction_id AND B.project_name = ''%s'';', $1)
     INTO _current_funding;

    RETURN _current_funding;
END; $$
LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS check_create_feedback ON Feedbacks;
CREATE TRIGGER check_create_feedback BEFORE INSERT ON Feedbacks
    FOR EACH ROW EXECUTE PROCEDURE check_create_feedback();

