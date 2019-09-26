CREATE TABLE Users (
	user_id serial PRIMARY KEY,
	email varchar(255) NOT NULL UNIQUE,
	full_name varchar(255) NOT NULL,
  phone_number varchar(255) NOT NULL UNIQUE,
  password_hash varchar(255) NOT NULL
);

CREATE TABLE Projects (
    project_id serial PRIMARY KEY,
    project_name varchar(255),
    project_description text,
    project_image_url varchar(255),
    owner_id int REFERENCES Users(user_id) ON DELETE CASCADE
);

CREATE TABLE Follows (
    follower_id int REFERENCES Users(user_id),
    following_id int REFERENCES Users(user_id),
    PRIMARY KEY(follower_id, following_id)
);

CREATE TABLE Likes (
    user_id int REFERENCES Users(user_id),
    project_id int REFERENCES Projects(project_id),
    CONSTRAINT likes_constraint PRIMARY KEY(user_id, project_id)
);

CREATE TABLE Backs (
    backs_id serial PRIMARY KEY,
    user_id int REFERENCES Users(user_id),
    project_id int REFERENCES Projects(project_id)
);

CREATE TABLE Transactions (
    transacton_id serial PRIMARY KEY,
    back_id int REFERENCES Backs(backs_id),
    amount numeric(20,2) NOT NULL
);

CREATE TABLE Creates (
    project_id int REFERENCES Projects(project_id),
    user_id int REFERENCES Users(user_id),
    CONSTRAINT creates_constraint PRIMARY KEY(user_id, project_id)
);

CREATE TABLE SearchHistory (
    search_id serial PRIMARY KEY,
    user_id int REFERENCES Users(user_id),
    search_text varchar(255)
);

CREATE TABLE PaymentInfo (
    paymentInfo_id serial PRIMARY KEY,
    user_id int REFERENCES Users(user_id) ON DELETE CASCADE,
    credit_card_number varchar(16),
    credit_card_expiry_month int,
    credit_card_expiry_year int,
    cv_number varchar(3),

    CONSTRAINT
      credit_card_expiry_month
      CHECK (credit_card_expiry_month BETWEEN 1 AND 12),
    CONSTRAINT
      credit_card_expiry_year
      CHECK (credit_card_expiry_year > (extract(epoch from date_trunc('year', CURRENT_DATE))::int))
);

CREATE TABLE ProjectFeedback (
    feedback_id serial PRIMARY KEY,
    project_id int REFERENCES Projects(project_id) ON DELETE CASCADE,
    comment_text text,
    rating_number int,

    CONSTRAINT
        feedback_not_null
        CHECK (comment_text IS NOT NULL OR rating_number IS NOT NULL)
);

CREATE TABLE UserFeedback(
    user_id int REFERENCES USERS(user_id),
    feedback_id int REFERENCES ProjectFeedback(feedback_id) ON DELETE CASCADE
);

CREATE TABLE ProjectUpdates (
    update_id serial,
    project_id int REFERENCES Projects(project_id) ON DELETE CASCADE,
    update_description text,
    update_date date,

    CONSTRAINT
      project_update_constraint
      PRIMARY KEY(update_id, project_id)
);

CREATE TABLE ProjectTiers (
    tier_id serial,
    project_id int REFERENCES Projects(project_id) ON DELETE CASCADE,
    threshold_amount numeric(20,2),
    reward_description text,
    PRIMARY KEY(project_id, tier_id),
    CONSTRAINT
      project_tier_constraint
      UNIQUE(project_id, threshold_amount)
);
