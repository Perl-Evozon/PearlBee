select setval('users_id_seq',
              ( select max( id ) from users ) + 1, true );

select setval('blog_id_seq',
              ( select max( id ) from blog ) + 1, true );

select setval('post_id_seq',
              ( select max( id ) from post ) + 1, true );

select setval('page_id_seq',
              ( select max( id ) from page ) + 1, true );

select setval('comment_id_seq',
              ( select max( id ) from comment ) + 1, true );

select setval('category_id_seq',
              ( select max( id ) from category ) + 1, true );

select setval('tag_id_seq',
              ( select max( id ) from tag ) + 1, true );

select setval('asset_id_seq',
              ( select max( id ) from asset ) + 1, true )
