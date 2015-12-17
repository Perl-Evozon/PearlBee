use utf8;
package PearlBee::Model::Schema::Result::Acl;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PearlBee::Model::Schema::Result::Acl - Access control lists.

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

=head1 TABLE: C<acl>

=cut

__PACKAGE__->table("acl");

=head1 ACCESSORS

=head2 name

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 255

=head2 ability

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "name",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 255 },
  "ability",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</name>

=item * L</ability>

=back

=cut

__PACKAGE__->set_primary_key("name", "ability");

=head1 RELATIONS

=head2 ability

Type: belongs_to

Related object: L<PearlBee::Model::Schema::Result::Ability>

=cut

__PACKAGE__->belongs_to(
  "ability",
  "PearlBee::Model::Schema::Result::Ability",
  { name => "ability" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 name

Type: belongs_to

Related object: L<PearlBee::Model::Schema::Result::Role>

=cut

__PACKAGE__->belongs_to(
  "name",
  "PearlBee::Model::Schema::Result::Role",
  { name => "name" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-12-17 13:13:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Ic8Ui67nye68YPlWBJ5hoA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
