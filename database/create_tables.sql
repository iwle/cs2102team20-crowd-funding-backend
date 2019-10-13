CREATE TABLE Users (
    user_id serial PRIMARY KEY,
	email varchar(255) NOT NULL UNIQUE,
	full_name varchar(255) NOT NULL,
    phone_number varchar(255) NOT NULL UNIQUE,
    password_hash varchar(255) NOT NULL
);

CREATE TABLE Projects (
    project_name varchar(255) PRIMARY KEY,
    project_description text,
    project_image_url varchar(255),
    user_id int REFERENCES Users(user_id) ON DELETE CASCADE
);

CREATE TABLE Follows (
    follower_id int REFERENCES Users(user_id),
    following_id int REFERENCES Users(user_id),
    CONSTRAINT follows_constraint PRIMARY KEY(follower_id, following_id)
);

CREATE TABLE Likes (
    user_id int REFERENCES Users(user_id),
    project_id int REFERENCES Projects(project_id),
    CONSTRAINT likes_constraint PRIMARY KEY(user_id, project_id)
);

CREATE TABLE Backs (
    user_id int REFERENCES Users(user_id),
    project_id int REFERENCES Projects(project_id),
    transaction_id int REFERENCES Transactions(transaction_id),
        back_date datetime NOT NULL,
    CONSTRAINT backs_constraint PRIMARY KEY(user_id, project_id, transaction_id)
);

CREATE TABLE Transactions (
    transacton_id serial PRIMARY KEY,
    back_id int REFERENCES Backs(backs_id),
    amount numeric(20,2) NOT NULL
);

CREATE TABLE Creates (
    project_name int REFERENCES Projects(project_name),
    user_id int REFERENCES Users(user_id),
    create_date datetime NOT NULL,
    CONSTRAINT creates_constraint PRIMARY KEY(user_id, project_id)
);

CREATE TABLE SearchHistory (
    search_timestamp timestamp,
    search_text varchar(255),
    CONSTRAINT searchhistory_timestamp PRIMARY KEY(search_timestamp)
);

CREATE TABLE Searches (
    search_timestamp timestamp REFERENCES SearchHistory(search_timestamp),
    user_id int REFERENCES Users(user_id),
    CONSTRAINT searches_constraint PRIMARY KEY(user_id, search_timestamp)
);

CREATE TABLE Wallets (
    user_id int REFERENCES Users(user_id) ON DELETE CASCADE,
    amount numeric,
    CONSTRAINT wallets_constraint PRIMARY KEY(user_id, amount)
);

CREATE TABLE Feedback (
    project_id int REFERENCES Projects(project_id) ON DELETE CASCADE,
    comment_text text,
    rating_number int,

    CONSTRAINT
        feedback_not_null
        CHECK (comment_text IS NOT NULL OR rating_number IS NOT NULL)
);

CREATE TABLE Rewards (
    project_id int REFERENCES Projects(project_id) ON DELETE CASCADE,
    threshold_amount numeric(20,2),
    reward_description text,
    PRIMARY KEY(project_id, tier_id),
    CONSTRAINT
      project_tier_constraint
      UNIQUE(project_id, threshold_amount)
);

CREATE TABLE Updates (
    project_id int REFERENCES Projects(project_id) ON DELETE CASCADE,
    update_description text,
    update_date date,

    CONSTRAINT
      project_update_constraint
      PRIMARY KEY(update_id, project_id)
);
