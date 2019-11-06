/*QUERY A Hyper funded projects
1. more than 2 x its funding goal
2. >= 100 backers
3. >= 150 likes*/

SELECT T1.project_name, COUNT(DISTINCT T1.liker) as likes ,COUNT(DISTINCT T2.email) as backs FROM
(SELECT T1.project_name, T1.project_image_url,T1.email AS creator, T2.email AS Liker
FROM Projects T1 LEFT JOIN Likes T2 
ON project_current_funding(T1.project_name) >= 2 * T1.project_funding_goal
AND T2.project_name = T1.project_name) T1 LEFT JOIN BackingFunds T2 
ON T1.project_name = T2.project_name
GROUP BY T1.project_name 
HAVING COUNT(DISTINCT T1.liker) >= 100 AND COUNT(DISTINCT T2.email) >= 150; 

/*QUERY B Hot users of the month LIMIT 3 
1. >= 100 followers
2.  Contributed >= $500 transactions made for ALL projects IN the past month*/

(SELECT T1.user_id, SUM(amount) FROM
(SELECT * FROM getAllFollowers() as T1 where T1.followers > 0) T1
LEFT JOIN (BackingFunds NATURAL JOIN Transactions) T2 
ON T1.user_id = T2.email
AND (LOCALTIMESTAMP - T2.transaction_date) <= interval '30 days'
GROUP BY T1.user_id 
HAVING SUM(amount) >= 0)

SELECT * FROM getAllFollowers() T1 NATURAL JOIN 
(SELECT T1.user_id, SUM(amount) FROM
(SELECT * FROM getAllFollowers() as T1 where T1.followers > 0) T1
LEFT JOIN (BackingFunds NATURAL JOIN Transactions) T2 
ON T1.user_id = T2.email
AND (LOCALTIMESTAMP - T2.transaction_date) <= interval '30 days'
GROUP BY T1.user_id 
HAVING SUM(amount) >= 0) T2;


/*QUERY C Most creative 
1. Has more than 5 projects
2. On average more than 500 likes
3. Has more than 2 projects in 2 different categories*/




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

CREATE OR REPLACE FUNCTION get_earliest_date_fully_funded_project (varchar(255))
    RETURNS timestamp
AS $$
    SELECT min_date
        FROM earliest_dates_fully_funded() AS earliest_dates
        WHERE earliest_dates.project_name = $1;
$$
LANGUAGE SQL;