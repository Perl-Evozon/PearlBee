

-- default admin login user : admin
-- default admin login pass : password


INSERT INTO ability
       VALUES('create blog'), ('view blog'  ),
             ('update blog'), ('delete blog'),
             ('create blog_category'), ('view blog_category'  ),
             ('update blog_category'), ('delete blog_category'),
             ('create blog_tag'), ('view blog_tag'  ),
             ('update blog_tag'), ('delete blog_tag'),

             ('create category'), ('view category'  ),
             ('update category'), ('delete category'),

             ('create comment'), ('view comment'  ),
             ('update comment'), ('delete comment'),

             ('create page'), ('view page'  ),
             ('update page'), ('delete page'),
             ('create page_category'), ('view page_category'  ),
             ('update page_category'), ('delete page_category'),
             ('create page_tag'), ('view page_tag'  ),
             ('update page_tag'), ('delete page_tag'),

             ('create post'), ('view post'  ),
             ('update post'), ('delete post'),
             ('create post_category'), ('view post_category'  ),
             ('update post_category'), ('delete post_category'),
             ('create post_tag'), ('view post_tag'  ),
             ('update post_tag'), ('delete post_tag'),

             ('create profile'), ('view profile'  ),
             ('update profile'), ('delete profile'),

             ('create tag'), ('view tag'  ),
             ('update tag'), ('delete tag'),

             ('create user'), ('view user'  ),
             ('update user'), ('delete user')
;


INSERT INTO role VALUES('admin'),
                       ('author'),
                       ('visitor');


INSERT INTO acl VALUES
       ('admin','create blog'),
       ('admin','view blog'  ),
       ('admin','update blog'),
       ('admin','delete blog'),
       ('admin','create blog_category'),
       ('admin','view blog_category'  ),
       ('admin','update blog_category'),
       ('admin','delete blog_category'),
       ('admin','create blog_tag'),
       ('admin','view blog_tag'  ),
       ('admin','update blog_tag'),
       ('admin','delete blog_tag'),

       ('admin','create category'),
       ('admin','view category'  ),
       ('admin','update category'),
       ('admin','delete category'),

       ('admin','create comment'),
       ('admin','view comment'  ),
       ('admin','update comment'),
       ('admin','delete comment'),

       ('admin','create page'),
       ('admin','view page'  ),
       ('admin','update page'),
       ('admin','delete page'),
       ('admin','create page_category'),
       ('admin','view page_category'  ),
       ('admin','update page_category'),
       ('admin','delete page_category'),
       ('admin','create page_tag'),
       ('admin','view page_tag'  ),
       ('admin','update page_tag'),
       ('admin','delete page_tag'),

       ('admin','create post'),
       ('admin','view post'  ),
       ('admin','update post'),
       ('admin','delete post'),
       ('admin','create post_category'),
       ('admin','view post_category'  ),
       ('admin','update post_category'),
       ('admin','delete post_category'),
       ('admin','create post_tag'),
       ('admin','view post_tag'  ),
       ('admin','update post_tag'),
       ('admin','delete post_tag'),

       ('admin','create profile'),
       ('admin','view profile'  ),
       ('admin','update profile'),
       ('admin','delete profile'),

       ('admin','create tag'),
       ('admin','view tag'  ),
       ('admin','update tag'),
       ('admin','delete tag'),

       ('admin','create user'),
       ('admin','view user'  ),
       ('admin','update user'),
       ('admin','delete user'),


       ('author','create blog'),
       ('author','view blog'  ),
       ('author','update blog'),
       ('author','delete blog'),
       ('author','create blog_category'),
       ('author','view blog_category'  ),
       ('author','update blog_category'),
       ('author','delete blog_category'),
       ('author','create blog_tag'),
       ('author','view blog_tag'  ),
       ('author','update blog_tag'),
       ('author','delete blog_tag'),

       ('author','create category'),
       ('author','view category'  ),
       ('author','update category'),
       ('author','delete category'),

       ('author','create comment'),
       ('author','view comment'  ),
       ('author','update comment'),
       ('author','delete comment'),

       ('author','create page'),
       ('author','view page'  ),
       ('author','update page'),
       ('author','delete page'),
       ('author','create page_category'),
       ('author','view page_category'  ),
       ('author','update page_category'),
       ('author','delete page_category'),
       ('author','create page_tag'),
       ('author','view page_tag'  ),
       ('author','update page_tag'),
       ('author','delete page_tag'),

       ('author','create post'),
       ('author','view post'  ),
       ('author','update post'),
       ('author','delete post'),
       ('author','create post_category'),
       ('author','view post_category'  ),
       ('author','update post_category'),
       ('author','delete post_category'),
       ('author','create post_tag'),
       ('author','view post_tag'  ),
       ('author','update post_tag'),
       ('author','delete post_tag'),

       ('author','create profile'),
       ('author','view profile'  ),
       ('author','update profile'),
       ('author','delete profile'),

       ('author','create tag'),
       ('author','view tag'  ),
       ('author','update tag'),
       ('author','delete tag'),

       -- ('author','create user'),
       -- ('author','view user'  ),
       -- ('author','update user'),
       -- ('author','delete user'),


       -- ('visitor','create blog'),
       ('visitor','view blog'  ),
       -- ('visitor','update blog'),
       -- ('visitor','delete blog'),
       -- ('visitor','create blog_category'),
       ('visitor','view blog_category'  ),
       -- ('visitor','update blog_category'),
       -- ('visitor','delete blog_category'),
       -- ('visitor','create blog_tag'),
       ('visitor','view blog_tag'  ),
       -- ('visitor','update blog_tag'),
       -- ('visitor','delete blog_tag'),

       -- ('visitor','create category'),
       ('visitor','view category'  ),
       -- ('visitor','update category'),
       -- ('visitor','delete category'),

       -- ('visitor','create comment'),
       ('visitor','view comment'  ),
       -- ('visitor','update comment'),
       -- ('visitor','delete comment'),

       -- ('visitor','create page'),
       ('visitor','view page'  ),
       -- ('visitor','update page'),
       -- ('visitor','delete page'),
       -- ('visitor','create page_category'),
       ('visitor','view page_category'  ),
       -- ('visitor','update page_category'),
       -- ('visitor','delete page_category'),
       -- ('visitor','create page_tag'),
       ('visitor','view page_tag'  ),
       -- ('visitor','update page_tag'),
       -- ('visitor','delete page_tag'),

       -- ('visitor','create post'),
       ('visitor','view post'  ),
       -- ('visitor','update post'),
       -- ('visitor','delete post'),
       -- ('visitor','create post_category'),
       ('visitor','view post_category'  ),
       -- ('visitor','update post_category'),
       -- ('visitor','delete post_category'),
       -- ('visitor','create post_tag'),
       ('visitor','view post_tag'  ),
       -- ('visitor','update post_tag'),
       -- ('visitor','delete post_tag'),

       -- ('visitor','create profile'),
       ('visitor','view profile'  ),
       -- ('visitor','update profile'),
       -- ('visitor','delete profile'),

       -- ('visitor','create tag'),
       ('visitor','view tag'  ),
       -- ('visitor','update tag'),
       -- ('visitor','delete tag'),

       -- ('visitor','create user'),
       ('visitor','view user'  )
       -- ('visitor','update user'),
       -- ('visitor','delete user')
;


INSERT INTO post_format VALUES('HTML'),
                              ('Markdown'),
                              ('Markdown_With_Smartypants'),
                              ('RichText'),
                              ('Textile2');


INSERT INTO theme VALUES('light'),
                        ('dark');


INSERT INTO oauth VALUES('LinekdIn'),
                        ('Facebook'),
                        ('GitHub'),
                        ('Twitter');

--
-- Administrator users are created during the import
--

-- INSERT INTO users VALUES (1,'Admin','admin','ddd8f33fbc8fd3ff70ea1d3768e7c5c151292d3a8c0972','2015-02-18 15:27:54','admin@admin.com',NULL,NULL,'admin',NULL,'active');
	
-- INSERT INTO category VALUES (1,'Uncategorized','uncategorized',1);


INSERT INTO settings VALUES ('Europe/Bucharest',1,'','/','BlogsPerlOrg',1,0);
