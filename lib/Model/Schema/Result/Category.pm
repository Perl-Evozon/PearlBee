package Model::Schema::Result::Category;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Model::Schema::Result::Category

=cut

__PACKAGE__->table("category");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

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
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "slug",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("name", ["name"]);

=head1 RELATIONS

=head2 user

Type: belongs_to

Related object: L<Model::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Model::Schema::Result::User",
  { id => "user_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 post_categories

Type: has_many

Related object: L<Model::Schema::Result::PostCategory>

=cut

__PACKAGE__->has_many(
  "post_categories",
  "Model::Schema::Result::PostCategory",
  { "foreign.category_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2014-01-29 19:41:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:KqRd2T04EHJ6NLrNC0Fjxg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
