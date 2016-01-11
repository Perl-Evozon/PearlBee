

-- default admin login user : admin
-- default admin login pass : password


INSERT INTO ability
       VALUES('create user'),('view user'),('update user'),('delete user'),
             ('create blog'),('view blog'),('update blog'),('delete blog'),
             ('create post'),('view post'),('update post'),('delete post');


INSERT INTO role VALUES('admin'),
                       ('author'),
                       ('visitor');


INSERT INTO acl VALUES('admin',   'create user'),
                      ('admin',   'view user'),
                      ('admin',   'delete user'),
                      ('author',  'create post'),
                      ('author',  'view post'),
                      ('author',  'delete post'),
                      ('visitor', 'view post');

--
-- Administrator users are created during the import
--

-- INSERT INTO "user" VALUES (1,'Admin','admin','ddd8f33fbc8fd3ff70ea1d3768e7c5c151292d3a8c0972','2015-02-18 15:27:54','admin@admin.com',NULL,NULL,'admin',NULL,'active');
	
-- INSERT INTO category VALUES (1,'Uncategorized','uncategorized',1);


INSERT INTO settings VALUES ('Europe/Bucharest',1,'','/','BlogsPerlOrg',1,0);
