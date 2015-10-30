package PearlBee::Model::Schema::Result::View::Count::TypePost;

# This view is used for counting all stauts

use strict;
use warnings;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');
__PACKAGE__->table('post');
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(
    q[
      SELECT
        post_type,
        SUM( status = 'published' ) AS published,
        SUM( status = 'trash') AS trash,
        SUM( status = 'draft' ) AS draft,
        COUNT(*) AS total
      FROM
        post
      GROUP BY
       post_type
    ]
);

__PACKAGE__->add_columns(
  "post_type",
  { data_type => "varchar", is_nullable => 0 },
  "published",
  { data_type => "integer", is_nullable => 0 },
  "trash",
  { data_type => "integer", is_nullable => 0 },
  "draft",
  { data_type => "integer", is_nullable => 0 },
  "total",
  { data_type => "integer", is_nullable => 0 },
);

1;