DELETE FROM Backingfunds;
DELETE FROM Comments;
DELETE FROM Creates;
DELETE FROM Feedbacks;
DELETE FROM Follows;
DELETE FROM Likes;
DELETE FROM Projects;
DELETE FROM Rewards;
DELETE FROM Searches;
DELETE FROM Searchhistory;
DELETE FROM Topupfunds;
DELETE FROM Transactions;
DELETE FROM Transferfunds;
DELETE FROM Updates;
DELETE FROM Users;
DELETE FROM Wallets;


-- INSERT INTO users
--     (email, full_name, phone_number, password_hash) VALUES
--     ('abi@example.com', 'Abi Dabhi', '91919292', 'stringpass_abi'),
--     ('babi@example.com', 'Babi Dabhi', '91919293', 'stringpass_babi'),
--     ('cabi@example.com', 'Cabi Dabhi', '91919294', 'stringpass_cabi'),
--     ('test@test.com', 'Test Man', '9', 'test');

CALL register('abi@example.com', 'Abi Dabhi', '91919292', 'stringpass_abi', localtimestamp - interval '34 days', localtimestamp - interval '2 days');
CALL register('babi@example.com', 'Babi Dabhi', '91919293', 'stringpass_babi', localtimestamp - interval '37 days', localtimestamp - interval '2 days');
CALL register('cabi@example.com', 'Cabi Dabhi', '91919294', 'stringpass_cabi', localtimestamp - interval '38 days', localtimestamp - interval '2 days');
CALL register('test@test.com', 'Test Man', '9', 'test');

UPDATE Wallets SET amount = 100000;

INSERT INTO projects
    (project_name, project_description, project_deadline,
        project_category, project_funding_goal,
        project_image_url, email) VALUES
    ('Spinning Table Top', 'A project that nobody really cares about. ' ||
     'Vivamus vehicula nisl sit amet nisi commodo, vitae semper lacus ullamcorper. Praesent sollicitudin ' ||
      'sed urna eget ullamcorper. Nam volutpat est libero, a vulputate lectus facilisis at. Pellentesque ' ||
       'habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nullam scelerisque ' ||
        'dolor sed mauris suscipit, id dapibus ipsum volutpat. In at bibendum sem. Duis id gravida enim.',
        '2019-10-15', 'Crafts', '4500', 'https://www.cheapdisabilityaids.co.uk/ekmps/shops/podcmedia/images/humming-top-1217-1-p.jpg',
        'abi@example.com'),
    ('Animal Abstraction Canvas Painting', 'A project that nobody really heard of. ' ||
     'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam sit amet bibendum nibh. Donec ' ||
      'faucibus id nisl sit amet pretium. Sed eu mauris nec ipsum luctus tempor vitae ut lorem. Quisque ' ||
       'accumsan, orci in consequat fermentum, nisl est porttitor leo, at feugiat nulla nunc vel lectus. ' ||
        'Suspendisse ullamcorper velit id risus vulputate tincidunt. Nam nec elementum nisl. Praesent sit ' ||
         'amet justo ullamcorper, cursus ex sed, pellentesque sem. Suspendisse fermentum efficitur quam quis ' ||
          'ultrices. Ut interdum sed nunc in maximus. Nunc ullamcorper eros at cursus vulputate. Quisque sed ' ||
           'commodo nunc, at consequat orci. Pellentesque a massa et orci pulvinar fermentum. Duis tincidunt ' ||
            'congue odio, ut auctor enim euismod a. Duis eget sagittis arcu. Praesent eget velit tristique, ' ||
             'viverra urna vel, euismod lacus.',
        '2019-12-30', 'Arts', '3000', 'https://images-na.ssl-images-amazon.com/images/I/81PXdx-ZTQL._SX466_.jpg',
        'babi@example.com'),
    ('Medical Tissue Pro', 'Medical magical tissue is back! It is a product that nobody really want to use.' ||
      'It uses many variations of passages of Lorem Ipsum available, but the majority have suffered alteration ' ||
       'in some form, by injected humour, or randomised words which don''t look even slightly believable. ' ||
        'If you are going to use a passage of Lorem Ipsum, you need to be sure there isn''t anything embarrassing ' ||
         'hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined ' ||
          'chunks as necessary, making this the first true generator on the Internet. It uses a dictionary of over ' ||
           '200 Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which ' ||
            'looks reasonable. The generated Lorem Ipsum is therefore always free from repetition, injected humour, ' ||
             'or non-characteristic words etc.',
        '2020-10-22', 'Arts', '75300', 'https://timedotcom.files.wordpress.com/2018/11/vaev-sick-tissue-02.jpg',
        'cabi@example.com'),
    ('Headphone Jack For Iphone', 'Headphone jack is back! Jack is a product that nobody really want to use.' ||
      'It uses many variations of passages of Lorem Ipsum available, but the majority have suffered alteration ' ||
       'in some form, by injected humour, or randomised words which don''t look even slightly believable. ' ||
        'If you are going to use a passage of Lorem Ipsum, you need to be sure there isn''t anything embarrassing ' ||
         'hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined ' ||
          'chunks as necessary, making this the first true generator on the Internet. It uses a dictionary of over ' ||
           '200 Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which ' ||
            'looks reasonable. The generated Lorem Ipsum is therefore always free from repetition, injected humour, ' ||
             'or non-characteristic words etc.',
        '2020-10-22', 'Electronics', '10000', 'https://images-na.ssl-images-amazon.com/images/I/61hXtN5cO7L._SX425_.jpg',
        'cabi@example.com'),
    ('Book Boom Speaker', 'Boom Boom Speaker is the world first speaker that boom the boomz. ' ||
     'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical ' ||
      'Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at ' ||
       'Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a ' ||
        'Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the ' ||
         'undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et ' ||
          'Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on ' ||
           'the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, ' ||
            '"Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.',
        '2020-10-22', 'Electronics', '4000', 'https://hnsfpau.imgix.net/5/images/detailed/95/all-colours.png?fit=fill&bg=0FFF&w=1500&h=844&auto=format,compress',
        'abi@example.com'),
    ('Clown of the Night', 'Clown is the world first speaker that boom the boomz. ' ||
     'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical ' ||
      'Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at ' ||
       'Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a ' ||
        'Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the ' ||
         'undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et ' ||
          'Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on ' ||
           'the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, ' ||
            '"Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.',
        '2019-10-22', 'Arts', '3000', 'https://cdn.britannica.com/98/196498-131-14B78278/Pennywise-Bill-Skarsgard-film-adaptation-novel-Stephen.jpg',
        'test@test.com'),
    ('Triathlete Mouse', 'Tri-mouse is the world first speaker that boom the boomz. ' ||
     'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical ' ||
      'Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at ' ||
       'Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a ' ||
        'Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the ' ||
         'undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et ' ||
          'Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on ' ||
           'the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, ' ||
            '"Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.',
        '2018-10-22', 'Electronics', '5000',  'https://static.techspot.com/images2/news/bigimage/2016/08/2016-08-31-image-4.png',
        'test@test.com'),
    ('Foldable Water Bottle', 'Foldy is the world first bottle that boom the boomz. ' ||
     'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical ' ||
      'Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at ' ||
       'Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a ' ||
        'Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the ' ||
         'undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et ' ||
          'Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on ' ||
           'the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, ' ||
            '"Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.',
        '2020-10-22', 'Crafts', '5000',  'https://ae01.alicdn.com/kf/HTB1fHqwr25TBuNjSspcq6znGFXaZ.jpg',
        'test@test.com');

INSERT INTO rewards
    (project_name, reward_name, reward_pledge_amount, reward_description) VALUES
    ('Spinning Table Top', 'Thank You Note', '200', 'A handwritten thank you useless note.'),
    ('Spinning Table Top', 'Super Early Bird Spinning Table Top', '1000', 'A spinning table top for your home ' ||
     'Integer accumsan justo quis consectetur molestie. Vivamus vitae purus a arcu rutrum eleifend. Fusce at ' ||
         'molestie id. Quisque pellentesque mi et ex tincidunt eleifend. Pellentesque ac pulvinar erat, sodales ' ||
          'lacinia enim. Phasellus ullamcorper lacinia justo vitae luctus.'),
    ('Spinning Table Top', 'Early Bird Spinning Table Top', '1200', 'A spinning Table top ' ||
     'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque semper blandit est in pellentesque. ' ||
      'In hac habitasse platea dictumst. Sed ut pulvinar libero. Ut mattis gravida tempor. Mauris et vehicula ' ||
       'odio, eu ultricies arcu. Suspendisse rhoncus accumsan purus, eu euismod dui porta ut. Curabitur in ' ||
        'vulputate ipsum. Praesent sit amet.'),
    ('Spinning Table Top', null, 0, null),
    ('Animal Abstraction Canvas Painting', 'ART Piece - Lion', '5000', 'Overpriced ART piece (LION) with artist signature.'),
    ('Animal Abstraction Canvas Painting', 'ART Piece - Cat', '3000', 'Overpriced ART piece (CAT) with artist signature.'),
    ('Animal Abstraction Canvas Painting', 'ART Piece - Mermaid', '15000', 'Overpriced ART piece (MERMAID) with artist signature.'),
    ('Animal Abstraction Canvas Painting', null, 0, null),
    ('Medical Tissue Pro', 'Used Tissue', '100', 'One box of used tissue for medical testing purposes.'),
    ('Medical Tissue Pro', 'Used Tissue (with flu)', '150', 'One box of used tissue (with flu) for medial testing purposes.'),
    ('Medical Tissue Pro', 'Used Tissue (with chronic disease)', '1000', 'One box of used tissue (with chronic disease) ' ||
     'for medial testing purposes.'),
    ('Medical Tissue Pro', null, 0, null),
    ('Headphone Jack For Iphone', 'Used Tissue', '100', 'One box of used tissue to wipe your tears while you think about your old friend jack.'),
    ('Headphone Jack For Iphone', null, 0, null),
    ('Book Boom Speaker', 'Super Early Bird Boom Speaker', '500', 'One Boom Speaker that changes your life. ' ||
     'Curabitur dictum lectus a dictum laoreet. Pellentesque vitae tellus leo. Curabitur condimentum lorem ' ||
      'sit amet vehicula laoreet. Praesent odio elit, pulvinar ut accumsan nec, varius porta augue. Aliquam ' ||
       'finibus tristique sem, non lobortis turpis rutrum non. Suspendisse nibh massa, auctor non arcu a, ' ||
        'imperdiet accumsan metus. In vitae quam non sapien auctor mattis. Proin fermentum odio eget arcu ' ||
         'varius luctus.'),
    ('Book Boom Speaker', 'Early Bird Boom Speaker', '530', 'One Boom Speaker that changes your life. ' ||
     'Curabitur dictum lectus a dictum laoreet. Pellentesque vitae tellus leo. Curabitur condimentum lorem ' ||
      'sit amet vehicula laoreet. Praesent odio elit, pulvinar ut accumsan nec, varius porta augue. Aliquam ' ||
       'finibus tristique sem, non lobortis turpis rutrum non. Suspendisse nibh massa, auctor non arcu a, ' ||
        'imperdiet accumsan metus. In vitae quam non sapien auctor mattis. Proin fermentum odio eget arcu ' ||
         'varius luctus.'),
    ('Book Boom Speaker', 'Bird Boom Speaker', '550', 'One Boom Speaker that changes your life. ' ||
     'Curabitur dictum lectus a dictum laoreet. Pellentesque vitae tellus leo. Curabitur condimentum lorem ' ||
      'sit amet vehicula laoreet. Praesent odio elit, pulvinar ut accumsan nec, varius porta augue. Aliquam ' ||
       'finibus tristique sem, non lobortis turpis rutrum non. Suspendisse nibh massa, auctor non arcu a, ' ||
        'imperdiet accumsan metus. In vitae quam non sapien auctor mattis. Proin fermentum odio eget arcu ' ||
         'varius luctus.'),
    ('Book Boom Speaker', 'Family Set - 3 x Boom Speaker', '2000', 'Three sets of Boom Speaker that changes your life. ' ||
     'Curabitur dictum lectus a dictum laoreet. Pellentesque vitae tellus leo. Curabitur condimentum lorem ' ||
      'sit amet vehicula laoreet. Praesent odio elit, pulvinar ut accumsan nec, varius porta augue. Aliquam ' ||
       'finibus tristique sem, non lobortis turpis rutrum non. Suspendisse nibh massa, auctor non arcu a, ' ||
        'imperdiet accumsan metus. In vitae quam non sapien auctor mattis. Proin fermentum odio eget arcu ' ||
         'varius luctus.'),
    ('Book Boom Speaker', null, 0, null),
    ('Clown of the Night', 'Family Set - 3 x Clown Mask', '100', 'Three sets of Boom Speaker that changes your life. ' ||
     'Curabitur dictum lectus a dictum laoreet. Pellentesque vitae tellus leo. Curabitur condimentum lorem ' ||
      'sit amet vehicula laoreet. Praesent odio elit, pulvinar ut accumsan nec, varius porta augue. Aliquam ' ||
       'finibus tristique sem, non lobortis turpis rutrum non. Suspendisse nibh massa, auctor non arcu a, ' ||
        'imperdiet accumsan metus. In vitae quam non sapien auctor mattis. Proin fermentum odio eget arcu ' ||
         'varius luctus.'),
    ('Clown of the Night', null, 0, null),
    ('Triathlete Mouse', 'Family Set - 3 x Mouse', '90', 'Three sets of Boom Speaker that changes your life. ' ||
     'Curabitur dictum lectus a dictum laoreet. Pellentesque vitae tellus leo. Curabitur condimentum lorem ' ||
      'sit amet vehicula laoreet. Praesent odio elit, pulvinar ut accumsan nec, varius porta augue. Aliquam ' ||
       'finibus tristique sem, non lobortis turpis rutrum non. Suspendisse nibh massa, auctor non arcu a, ' ||
        'imperdiet accumsan metus. In vitae quam non sapien auctor mattis. Proin fermentum odio eget arcu ' ||
         'varius luctus.'),
    ('Triathlete Mouse', null, 0, null),
    ('Foldable Water Bottle', 'Super Early Bird Water Bottle', '600', 'One bottle that changes your life. ' ||
     'Curabitur dictum lectus a dictum laoreet. Pellentesque vitae tellus leo. Curabitur condimentum lorem ' ||
      'sit amet vehicula laoreet. Praesent odio elit, pulvinar ut accumsan nec, varius porta augue. Aliquam ' ||
       'finibus tristique sem, non lobortis turpis rutrum non. Suspendisse nibh massa, auctor non arcu a, ' ||
        'imperdiet accumsan metus. In vitae quam non sapien auctor mattis. Proin fermentum odio eget arcu ' ||
         'varius luctus.'),
    ('Foldable Water Bottle', 'Early Bird Water Bottle', '650', 'One bottle that changes your life. ' ||
     'Curabitur dictum lectus a dictum laoreet. Pellentesque vitae tellus leo. Curabitur condimentum lorem ' ||
      'sit amet vehicula laoreet. Praesent odio elit, pulvinar ut accumsan nec, varius porta augue. Aliquam ' ||
       'finibus tristique sem, non lobortis turpis rutrum non. Suspendisse nibh massa, auctor non arcu a, ' ||
        'imperdiet accumsan metus. In vitae quam non sapien auctor mattis. Proin fermentum odio eget arcu ' ||
         'varius luctus.'),
    ('Foldable Water Bottle', null, 0, null);



INSERT INTO updates
    (project_name, update_title, update_description, update_time) VALUES
    ('Spinning Table Top', 'Woah! We have reached our funding goal!',
    'Well that was fast! We just hit our $10K goal in 19 minutes. ' ||
     'We are floored by the early and enthusiastic support. ' ||
      'We will have a bunch of additional updates to share, but for now we just ' ||
       'wanted to say thank you to everyone who got on board early. ', '2019-08-02 16:04:56.874028'),
    ('Spinning Table Top', '3 days, 1313 backers',
    'Hello again! We are 3 days into our campaign right now, and we''re at 1313 backers. ' ||
     'That is a truly astonishing number of people. I ' ||
     'have been trying to visualize that number of people in a room, and all I can think ' ||
      'of is a very large, very full music venue. And thats all of you! Thank you again ' ||
       'for going on this journey with us and placing your trust in us. We are looking forward ' ||
        'to delighting you with this special little object.', '2019-09-02 16:04:56.874028'),
    ('Animal Abstraction Canvas Painting', 'Time to party!!!',
    'We just hit our $100K goal in 5 minutes.' ||
     ' We are floored by the early and enthusiastic support. ' ||
      'We will have a bunch of additional updates to share, but for now we just ' ||
       'wanted to say thank you to everyone who got on board early. ', '2019-08-02 16:04:56.874028'),
    ('Animal Abstraction Canvas Painting', '5000 Backers and counting',
    'Hello again! We are 3 days into our campaign right now,'
    ' and we''re at 1313 backers. That is a truly astonishing number of people. I have been trying to ' ||
     'visualize that number of people in a room, and all I can think of is a very large, ' ||
      'very full music venue. And that''s all of you! Thank you again for going on this journey with us and placing ' ||
       'your trust in us. We are looking forward to delighting you with this special little object.',
    '2019-09-02 16:04:56.874028');

INSERT INTO comments
    (project_name, comment_text, comment_date, email) VALUES
    ('Spinning Table Top', 'Where will is be manufactured?', '2019-06-02 16:04:56.874028', 'test@test.com'),
    ('Spinning Table Top', 'Ok great!', '2019-06-02 18:04:56.874028', 'test@test.com'),
    ('Spinning Table Top', 'This seems like a great product! I am definitely backing this',
    '2019-06-02 13:04:56.874028', 'test@test.com'),
    ('Animal Abstraction Canvas Painting', 'So exicted for this!',
    '2019-06-02 13:04:56.874028', 'abi@example.com'),
    ('Animal Abstraction Canvas Painting', 'Backed. As I always say on your Instagram. Take my money lol',
    '2019-06-02 13:00:56.874028', 'babi@example.com'),
    ('Animal Abstraction Canvas Painting', 'Hahaha, excellent. Now you have smashed that goal, can I also get my mitts on a cubic ' ||
     'square inch thats been out of stock for what feels like most of my life lol.',
    '2019-07-02 13:00:56.874028', 'babi@example.com'),
    ('Animal Abstraction Canvas Painting', 'Backed as soon as I seen your puzzle on MRPuzzles Youtube. Cant ' ||
     'wait to receive it. Looks an incredible design.',
    '2019-06-02 13:00:56.874028', 'cabi@example.com');

-- Insert Transactions and Backings
SELECT backs('test@test.com', 'Animal Abstraction Canvas Painting', 'ART Piece - Lion', 5000);
SELECT backs('test@test.com', 'Medical Tissue Pro', 'Used Tissue', 5000);
SELECT backs('test@test.com', 'Medical Tissue Pro', 'Used Tissue (with flu)', 5000);
SELECT backs('test@test.com', 'Medical Tissue Pro', 'Used Tissue (with chronic disease)', 5000);
SELECT backs('test@test.com', 'Medical Tissue Pro', null, 200);
SELECT backs('abi@example.com', 'Medical Tissue Pro', 'Used Tissue (with flu)', 3000);
SELECT backs('abi@example.com', 'Spinning Table Top', 'Early Bird Spinning Table Top', 2000);
SELECT backs('test@test.com', 'Spinning Table Top', 'Early Bird Spinning Table Top', 2000);
SELECT backs('babi@example.com', 'Triathlete Mouse', 'Family Set - 3 x Mouse', 90);
SELECT backs('babi@example.com', 'Triathlete Mouse', null, 5000);

-- This should fail as Triathelete Mouse is a project that belongs that to feedbacker.
CALL create_feedback('Triathlete Mouse', 'This is the most awesome project I have ever backed', 4, 'test@test.com');

-- This should fail as project is still live.
CALL create_feedback('Medical Tissue Pro', 'This is the most awesome project I have ever backed', 3, 'test@test.com');

-- This should fail as project is still live
CALL create_feedback('Medical Tissue Pro', 'This is the most awesome project I have ever backed', 3, 'abi@example.com');

-- This should fail as project has not reach funding goal, $500 short
CALL create_feedback('Spinning Table Top', 'This is the most awesome project I have ever backed', 3, 'test@test.com');

SELECT backs('test@test.com', 'Spinning Table Top', 'Super Early Bird Spinning Table Top', 2000);

-- This should pass now as project has reached funding goal
CALL create_feedback('Spinning Table Top', 'This is the most awesome project I have ever backed', 3, 'test@test.com');
