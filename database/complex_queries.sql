/* Find the earliest date that the project is fully funded before the deadline */
CREATE OR REPLACE FUNCTION earliest_dates_fully_funded ()
    RETURNS TABLE(project_name varchar(255), min_date timestamp)
AS $$ BEGIN
    RETURN QUERY SELECT Q.project_name project_name, MIN(transaction_date) min_date FROM Transactions T
        JOIN (
            SELECT P.project_name, transaction_id FROM Projects P
                JOIN BackingFunds B ON B.project_name = P.project_name
            WHERE project_funding_goal <= project_current_funding) AS Q
        ON T.transaction_id = Q.transaction_id
        GROUP BY Q.project_name;
END; $$
LANGUAGE PLPGSQL;