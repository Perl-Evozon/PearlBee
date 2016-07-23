use utf8;
package PearlBee::Model::Schema::Result::Category;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PearlBee::Model::Schema::Result::Category

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<category>

=cut

__PACKAGE__->table("category");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'category_id_seq'

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 slug

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "category_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "slug",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<category_name_key>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("category_name_key", ["name"]);

=head1 RELATIONS

=head2 post_categories

Type: has_many

Related object: L<PearlBee::Model::Schema::Result::PostCategory>

=cut

__PACKAGE__->has_many(
  "post_categories",
  "PearlBee::Model::Schema::Result::PostCategory",
  { "foreign.category_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user

Type: belongs_to

Related object: L<PearlBee::Model::Schema::Result::MyUser>

=cut

__PACKAGE__->belongs_to(
  "user",
  "PearlBee::Model::Schema::Result::MyUser",
  { id => "user_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 posts

Type: many_to_many

Composing rels: L</post_categories> -> post

=cut

__PACKAGE__->many_to_many("posts", "post_categories", "post");


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-07-23 09:11:12
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8ifjVAmvPtfFa7iZKqKODA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
