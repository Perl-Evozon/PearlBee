use utf8;
package PearlBee::Model::Schema::Result::BlogOwner;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PearlBee::Model::Schema::Result::BlogOwner - Blog owners.

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

=head1 TABLE: C<blog_owners>

=cut

__PACKAGE__->table("blog_owners");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 blog_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 created_date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 status

  data_type: 'enum'
  default_value: 'inactive'
  extra: {list => ["inactive","active","suspended","pending"]}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "blog_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "created_date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "status",
  {
    data_type => "enum",
    default_value => "inactive",
    extra => { list => ["inactive", "active", "suspended", "pending"] },
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</user_id>

=item * L</blog_id>

=back

=cut

__PACKAGE__->set_primary_key("user_id", "blog_id");

=head1 RELATIONS

=head2 blog

Type: belongs_to

Related object: L<PearlBee::Model::Schema::Result::Blog>

=cut

__PACKAGE__->belongs_to(
  "blog",
  "PearlBee::Model::Schema::Result::Blog",
  { id => "blog_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 user

Type: belongs_to

Related object: L<PearlBee::Model::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "PearlBee::Model::Schema::Result::User",
  { id => "user_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-12-17 13:13:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Y5I5gw8JaqHNb5Ns+Dn03A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
