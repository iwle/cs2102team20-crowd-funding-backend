/*QUERY A Hyper funded projects
1. more than 2 x its funding goal
2. >= 100 backers
3. >= 150 likes*/

CREATE OR REPLACE FUNCTION get_hyper_projects()
    RETURNS TABLE(project varchar(255), likes bigint, backers bigint)
AS $$ BEGIN
RETURN QUERY 

SELECT T1.project_name, COUNT(DISTINCT T1.liker) as likes ,COUNT(DISTINCT T2.email) as backs FROM
(SELECT T1.project_name, T1.project_image_url,T1.email AS creator, T2.email AS Liker
FROM Projects T1 LEFT JOIN Likes T2 
ON project_current_funding(T1.project_name) >= 2 * T1.project_funding_goal
AND T2.project_name = T1.project_name) T1 LEFT JOIN BackingFunds T2 
ON T1.project_name = T2.project_name
GROUP BY T1.project_name 
HAVING COUNT(DISTINCT T1.liker) >= 150 AND COUNT(DISTINCT T2.email) >= 100; 

END; $$
LANGUAGE PLPGSQL;


/*QUERY B Featured backers of the month (LIMIT 3) 
1.  >= 100 followers
2.  Contributed >= $500 transactions made for ALL projects IN the past month
3.  Backed at least 5 projects in the past month*/

CREATE OR REPLACE FUNCTION get_featured_backers()
    RETURNS TABLE(backer varchar(255), followers bigint, amount numeric)
AS $$ BEGIN 
RETURN QUERY

    SELECT * FROM getAllFollowers() T1 NATURAL JOIN 
    (SELECT T1.user_id, SUM(T2.amount) FROM
    (SELECT * FROM getAllFollowers() as T1 where T1.followers >= 100) T1
    LEFT JOIN (BackingFunds NATURAL JOIN Transactions) T2 
    ON T1.user_id = T2.email
    AND (LOCALTIMESTAMP - T2.transaction_date) <= interval '30 days'
    GROUP BY T1.user_id 
    HAVING SUM(T2.amount) >= 500 AND COUNT(DISTINCT project_name)>=5) T2 
    LIMIT 3;
    
END; $$
LANGUAGE PLPGSQL;


/*QUERY C  Featured project creators (Top 3) 
1. Has more than 5 projects
2. On average more than 500 likes
3. Has projects in at least 3 different categories*/

CREATE OR REPLACE FUNCTION get_featured_creators ()
    RETURNS TABLE(creator varchar(255), projects bigint, categories bigint, likes bigint)

AS $$ BEGIN
RETURN QUERY 
    SELECT T1.email AS creator, COUNT(DISTINCT T1.project_name) AS projects,
    COUNT(DISTINCT T1.project_category) AS categories,
    COUNT(T2.email) / COUNT(DISTINCT T1.project_name) AS avg_likes
    FROM Projects T1 LEFT JOIN LIKES T2 
    ON T1.project_name = T2.project_name
    GROUP BY T1.email
    HAVING COUNT(DISTINCT T1.project_name) >= 5
    AND COUNT(DISTINCT T1.project_category) >=3
    AND COUNT(T2.email) / COUNT(DISTINCT T1.project_name) >= 500
    LIMIT 3;
END; $$
LANGUAGE PLPGSQL;

/* Fast funded projects: Projects that are fully funded within 2 weeks*/
CREATE OR REPLACE FUNCTION fast_funded_projects()
    RETURNS TABLE(project_name varchar(255), timetaken interval)

AS $$ BEGIN
    RETURN QUERY 
    SELECT projects.project_name, LOCALTIMESTAMP - get_earliest_date_fully_funded_project(projects.project_name)
    FROM projects WHERE (LOCALTIMESTAMP - get_earliest_date_fully_funded_project(projects.project_name)) <= interval '14 days';

END; $$
LANGUAGE PLPGSQL;
  

/* Find the earliest date that the project is fully funded before the deadline */
CREATE OR REPLACE FUNCTION earliest_dates_fully_funded ()
    RETURNS TABLE(project_name varchar(255), min_date timestamp)
AS $$ BEGIN
    RETURN QUERY SELECT Q.project_name project_name, MIN(transaction_date) min_date FROM Transactions T
        JOIN (
            SELECT P.project_name, transaction_id FROM Projects P
                JOIN BackingFunds B ON B.project_name = P.project_name
            WHERE project_funding_goal <= project_current_funding(P.project_name)) AS Q
        ON T.transaction_id = Q.transaction_id
        GROUP BY Q.project_name;
END; $$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION get_earliest_date_fully_funded_project (varchar(255))
    RETURNS timestamp
AS $$
DECLARE 
earliest_date timestamp;
BEGIN 
    SELECT MIN(min_date) INTO earliest_date
        FROM earliest_dates_fully_funded() AS earliest_dates
        WHERE earliest_dates.project_name = $1;
        RETURN earliest_date;
END $$
LANGUAGE PLPGSQL;

