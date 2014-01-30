package Model::Schema::Result::View::UserComments;

# This view is used for grabbing comments per user

use strict;
use warnings;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');
__PACKAGE__->table('comment');
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(
    q[
        SELECT
            C.content AS content, C.id AS id, C.comment_date AS comment_date, C.email AS email, C.status as status, C.fullname AS fullname, P.title AS post_title, P.id AS post_id
        FROM
            comment as C
            INNER JOIN
                post AS P
                ON
                    P.id = C.post_id
            INNER JOIN user AS U
                ON
                    P.user_id = U.id
        WHERE
            U.id = ?
    ]
);

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "content",
  { data_type => "text", is_nullable => 1 },
  "fullname",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "comment_date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "status",
  {
    data_type => "enum",
    default_value => "pending",
    extra => { list => ["approved", "spam", "pending", "trash"] },
    is_nullable => 1,
  },
  "post_title",
  { data_type => "text", is_nullable => 1 },
  "post_id",
  { data_type => "integer" },
);
__PACKAGE__->set_primary_key("id");

__PACKAGE__->belongs_to(
  "post",
  "Model::Schema::Result::Post",
  { id => "post_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


1;