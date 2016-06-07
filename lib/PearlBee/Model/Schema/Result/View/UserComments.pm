package PearlBee::Model::Schema::Result::View::UserComments;

# This view is used for grabbing comments per user

use strict;
use warnings;
use base qw/DBIx::Class::Core/;

use Dancer2;
my $user_table = config->{ user_table };

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');
__PACKAGE__->table('comment');
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(
   qq[
      SELECT
        C.content AS content, C.id AS id, C.uid AS uid, C.reply_to AS reply_to, C.comment_date AS comment_date, C.email AS email, C.status as status, C.fullname AS fullname, P.title AS post_title, P.id AS post_id
    FROM
      comment as C
      INNER JOIN
        post AS P
        ON
          P.id = C.post_id
      INNER JOIN $user_table AS U
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
  "uid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "reply_to",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

__PACKAGE__->belongs_to(
  "post",
  "PearlBee::Model::Schema::Result::Post",
  { id => "post_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 uid

Type: belongs_to

Related object: L<PearlBee::Model::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "uid",
  "PearlBee::Model::Schema::Result::User",
  { id => "uid" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);


1;
