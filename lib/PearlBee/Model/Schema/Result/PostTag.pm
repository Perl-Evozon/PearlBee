use utf8;
package PearlBee::Model::Schema::Result::PostTag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PearlBee::Model::Schema::Result::PostTag

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<post_tag>

=cut

__PACKAGE__->table("post_tag");

=head1 ACCESSORS

=head2 tag_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 post_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "tag_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "post_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</tag_id>

=item * L</post_id>

=back

=cut

__PACKAGE__->set_primary_key("tag_id", "post_id");

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

=head2 tag

Type: belongs_to

Related object: L<PearlBee::Model::Schema::Result::Tag>

=cut

__PACKAGE__->belongs_to(
  "tag",
  "PearlBee::Model::Schema::Result::Tag",
  { id => "tag_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-02-08 22:14:01
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AAXCxuOT0MQPMvUoUnCZSQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
