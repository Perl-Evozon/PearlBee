use utf8;
package PearlBee::Model::Schema::Result::Tag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PearlBee::Model::Schema::Result::Tag

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<tag>

=cut

__PACKAGE__->table("tag");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'tag_id_seq'

=head2 name

  data_type: 'varchar'
  default_value: null
  is_nullable: 1
  size: 100

=head2 slug

  data_type: 'varchar'
  default_value: null
  is_nullable: 1
  size: 100

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "tag_id_seq",
  },
  "name",
  {
    data_type => "varchar",
    default_value => \"null",
    is_nullable => 1,
    size => 100,
  },
  "slug",
  {
    data_type => "varchar",
    default_value => \"null",
    is_nullable => 1,
    size => 100,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 post_tags

Type: has_many

Related object: L<PearlBee::Model::Schema::Result::PostTag>

=cut

__PACKAGE__->has_many(
  "post_tags",
  "PearlBee::Model::Schema::Result::PostTag",
  { "foreign.tag_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 posts

Type: many_to_many

Composing rels: L</post_tags> -> post

=cut

__PACKAGE__->many_to_many("posts", "post_tags", "post");


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-07-23 09:11:12
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:j/OXmi/fEsUc8z19S6nzeA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->load_components(qw/UTF8Columns/);
__PACKAGE__->utf8_columns(qw/name/);
1;
