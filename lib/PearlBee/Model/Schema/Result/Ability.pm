use utf8;
package PearlBee::Model::Schema::Result::Ability;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PearlBee::Model::Schema::Result::Ability - List of user abilities.

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

=head1 TABLE: C<ability>

=cut

__PACKAGE__->table("ability");

=head1 ACCESSORS

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->set_primary_key("name");

=head1 RELATIONS

=head2 acls

Type: has_many

Related object: L<PearlBee::Model::Schema::Result::Acl>

=cut

__PACKAGE__->has_many(
  "acls",
  "PearlBee::Model::Schema::Result::Acl",
  { "foreign.ability" => "self.name" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 names

Type: many_to_many

Composing rels: L</acls> -> name

=cut

__PACKAGE__->many_to_many("names", "acls", "name");


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-11-23 12:42:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2PvPRk5xCx4b5RkCJXTa7Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
