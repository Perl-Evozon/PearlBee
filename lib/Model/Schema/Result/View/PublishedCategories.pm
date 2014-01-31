package Model::Schema::Result::View::PublishedCategories;

# This view is used for grabbing all Categories that contain only published posts

use strict;
use warnings;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');
__PACKAGE__->table('category');
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(
    q[
      SELECT DISTINCT
        C.name, C.id, C.user_id, C.slug
      	FROM 
      		category AS C 
			  INNER JOIN 
      		post_category AS PC ON PC.category_id = C.id 
        INNER JOIN 
      		post as P ON P.id = PC.post_id 
        WHERE 
      			P.status = 'published'
    ]
);

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "slug",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

1;
