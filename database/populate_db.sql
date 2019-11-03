DELETE FROM users;
DELETE FROM projects;
DELETE FROM rewards;
DELETE FROM updates;
DELETE FROM comments;
DELETE FROM wallets;

INSERT INTO users
    (email, full_name, phone_number, password_hash) VALUES
    ('abi@example.com', 'Abi Dabhi', '91919292', 'stringpass_abi'),
    ('babi@example.com', 'Babi Dabhi', '91919293', 'stringpass_babi'),
    ('cabi@example.com', 'Cabi Dabhi', '91919294', 'stringpass_cabi'),
    ('test@test.com', 'Test Man', '9', 'test');

INSERT INTO projects
    (project_name, project_description, project_deadline,
        project_category, project_funding_goal, project_current_funding,
        project_image_url, email) VALUES
    ('Project 1', 'A project that nobody really cares about.',
        '2019-10-15', 'Crafts', '45000', '0', 'https://unsplash.com/photos/B1KFwtFFZl8',
        'abi@example.com'),
    ('Project 2', 'A project that nobody really heard of.',
        '2019-12-30', 'Arts', '3000', '0', 'https://unsplash.com/photos/B1KFwtFFZl8',
        'babi@example.com'),
    ('Project 3', 'A project that nobody really want to use.',
        '2020-10-22', 'Electronics', '1000000', '0', 'https://unsplash.com/photos/B1KFwtFFZl8',
        'cabi@example.com');

INSERT INTO rewards
    (project_name, reward_name, reward_pledge_amount, reward_description, reward_tier_id) VALUES
    ('Project 1', 'Thank You Note', '200', 'A handwritten thank you useless note.', 1),
    ('Project 2', 'ART Piece - Lion', '5000', 'Overpriced ART piece (LION) with artist signature.', 1),
    ('Project 2', 'ART Piece - Cat', '3000', 'Overpriced ART piece (CAT) with artist signature.', 2),
    ('Project 2', 'ART Piece - Mermaid', '15000', 'Overpriced ART piece (MERMAID) with artist signature.', 3);

INSERT INTO updates
    (project_name, update_title, update_description, update_time) VALUES
    ('Project 1', 'Woah! We have reached our funding goal!',
    'Well that was fast! We just hit our $10K goal in 19 minutes. ' ||
     'We are floored by the early and enthusiastic support. ' ||
      'We will have a bunch of additional updates to share, but for now we just ' ||
       'wanted to say thank you to everyone who got on board early. ', '2019-08-02 16:04:56.874028'),
    ('Project 1', '3 days, 1313 backers',
    'Hello again! We are 3 days into our campaign right now, and we''re at 1313 backers. ' ||
     'That is a truly astonishing number of people. I ' ||
     'have been trying to visualize that number of people in a room, and all I can think ' ||
      'of is a very large, very full music venue. And thats all of you! Thank you again ' ||
       'for going on this journey with us and placing your trust in us. We are looking forward ' ||
        'to delighting you with this special little object.', '2019-09-02 16:04:56.874028'),
    ('Project 2', 'Time to party!!!',
    'We just hit our $100K goal in 5 minutes.' ||
     ' We are floored by the early and enthusiastic support. ' ||
      'We will have a bunch of additional updates to share, but for now we just ' ||
       'wanted to say thank you to everyone who got on board early. ', '2019-08-02 16:04:56.874028'),
    ('Project 2', '5000 Backers and counting',
    'Hello again! We are 3 days into our campaign right now,'
    ' and we''re at 1313 backers. That is a truly astonishing number of people. I have been trying to ' ||
     'visualize that number of people in a room, and all I can think of is a very large, ' ||
      'very full music venue. And that''s all of you! Thank you again for going on this journey with us and placing ' ||
       'your trust in us. We are looking forward to delighting you with this special little object.',
    '2019-09-02 16:04:56.874028');

INSERT INTO comments
    (project_name, comment_text, comment_date, email) VALUES
    ('Project 1', 'Where will is be manufactured?', '2019-06-02 16:04:56.874028', 'test@test.com'),
    ('Project 1', 'Ok great!', '2019-06-02 18:04:56.874028', 'test@test.com'),
    ('Project 2', 'This seems like a great product! I am definitely backing this',
    '2019-06-02 13:04:56.874028', 'test@test.com'),
    ('Project 2', 'So exicted for this!',
    '2019-06-02 13:04:56.874028', 'abi@example.com'),
    ('Project 2', 'Backed. As I always say on your Instagram. Take my money lol',
    '2019-06-02 13:00:56.874028', 'babi@example.com'),
    ('Project 2', 'Hahaha, excellent. Now you have smashed that goal, can I also get my mitts on a cubic ' ||
     'square inch thats been out of stock for what feels like most of my life lol.',
    '2019-07-02 13:00:56.874028', 'babi@example.com'),
    ('Project 2', 'Backed as soon as I seen your puzzle on MRPuzzles Youtube. Cant ' ||
     'wait to receive it. Looks an incredible design.',
    '2019-06-02 13:00:56.874028', 'cabi@example.com');

INSERT INTO wallets
    (email, amount) VALUES
    ('abi@example.com', 4000),
    ('babi@example.com', 6000),
    ('test@test.com', 500000);

-- Insert Transactions and Backings
SELECT backs('test@test.com', 'Project 2', 'ART Piece - Lion', 5000);
SELECT backs('test@test.com', 'Project 2', 'ART Piece - Cat', 3000);
