use utf8;
package PearlBee::Model::Schema::Result::Blog;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PearlBee::Model::Schema::Result::Blog - Blog information.

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 TABLE: C<blog>

=cut

__PACKAGE__->table("blog");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 512

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 512

=head2 created_date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 edited_date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: '0000-00-00 00:00:00'
  is_nullable: 0

=head2 status

  data_type: 'enum'
  default_value: 'inactive'
  extra: {list => ["inactive","active","suspended","pending"]}
  is_nullable: 0

=head2 commenting_allowed

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

=head2 moderating_enabled

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 email_author_at_new_comments

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

=head2 email_others_at_new_comments

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 512 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 512 },
  "created_date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "edited_date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => "0000-00-00 00:00:00",
    is_nullable => 0,
  },
  "status",
  {
    data_type => "enum",
    default_value => "inactive",
    extra => { list => ["inactive", "active", "suspended", "pending"] },
    is_nullable => 0,
  },
  "commenting_allowed",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
  "moderating_enabled",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "email_author_at_new_comments",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
  "email_others_at_new_comments",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 assets

Type: has_many

Related object: L<PearlBee::Model::Schema::Result::Asset>

=cut

__PACKAGE__->has_many(
  "assets",
  "PearlBee::Model::Schema::Result::Asset",
  { "foreign.blog_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 blog_owners

Type: has_many

Related object: L<PearlBee::Model::Schema::Result::BlogOwner>

=cut

__PACKAGE__->has_many(
  "blog_owners",
  "PearlBee::Model::Schema::Result::BlogOwner",
  { "foreign.blog_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-12-17 13:13:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YIykI00XPssdxzPzPinC9g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
