DELETE FROM users;
DELETE FROM projects;
DELETE FROM rewards;

INSERT INTO users (email, full_name, phone_number, password_hash) VALUES
('abi@example.com', 'Abi Dabhi', '91919292', 'stringpass_abi'),
('babi@example.com', 'Babi Dabhi', '91919293', 'stringpass_babi'),
('cabi@example.com', 'Cabi Dabhi', '91919294', 'stringpass_cabi');

INSERT INTO projects (project_name, project_description, project_deadline,
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

INSERT INTO rewards (project_name, reward_name, reward_pledge_amount, reward_description,
reward_tier_id) VALUES
('Project 1', 'Thank You Note', '200', 'A handwritten thank you useless note.', 1),
('Project 2', 'ART Piece - Lion', '5000', 'Overpriced ART piece (LION) with artist signature.', 1),
('Project 2', 'ART Piece - Cat', '3000', 'Overpriced ART piece (CAT) with artist signature.', 2),
('Project 2', 'ART Piece - Mermaid', '15000', 'Overpriced ART piece (MERMAID) with artist signature.', 3);
