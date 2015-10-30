use utf8;
package PearlBee::Model::Schema::Result::PostMeta;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PearlBee::Model::Schema::Result::PostMeta - Post metadata table.

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<post_meta>

=cut

__PACKAGE__->table("post_meta");

=head1 ACCESSORS

=head2 post_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 meta_key

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 meta_value

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "post_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "meta_key",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "meta_value",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</post_id>

=item * L</meta_key>

=back

=cut

__PACKAGE__->set_primary_key("post_id", "meta_key");

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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-10-29 15:38:12
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qenlJZdQsLV4K/pOEHs5Uw


# You can replace this text with custom code or comments, and it will be preserved on regeneration

1;
