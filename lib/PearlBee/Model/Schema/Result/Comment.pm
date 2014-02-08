use utf8;
package PearlBee::Model::Schema::Result::Comment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PearlBee::Model::Schema::Result::Comment

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<comment>

=cut

__PACKAGE__->table("comment");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 content

  data_type: 'text'
  is_nullable: 1

=head2 fullname

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 email

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 website

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 avatar

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 comment_date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 status

  data_type: 'enum'
  default_value: 'pending'
  extra: {list => ["approved","spam","pending","trash"]}
  is_nullable: 1

=head2 post_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "content",
  { data_type => "text", is_nullable => 1 },
  "fullname",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "website",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "avatar",
  { data_type => "varchar", is_nullable => 1, size => 255 },
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
  "post_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 post

Type: belongs_to

Related object: L<PearlBee::Model::Schema::Result::Post>

=cut

__PACKAGE__->belongs_to(
  "post",
  "PearlBee::Model::Schema::Result::Post",
  { id => "post_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-02-08 22:14:01
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:QPLwCfbuO716Kz3nMVw65Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
