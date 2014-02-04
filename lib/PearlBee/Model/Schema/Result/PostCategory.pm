package PearlBee::Model::Schema::Result::PostCategory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

PearlBee::Model::Schema::Result::PostCategory

=cut

__PACKAGE__->table("post_category");

=head1 ACCESSORS

=head2 category_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 post_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "category_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "post_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("category_id", "post_id");

=head1 RELATIONS

=head2 category

Type: belongs_to

Related object: L<PearlBee::Model::Schema::Result::Category>

=cut

__PACKAGE__->belongs_to(
  "category",
  "PearlBee::Model::Schema::Result::Category",
  { id => "category_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 post

Type: belongs_to

Related object: L<PearlBee::Model::Schema::Result::Post>

=cut

__PACKAGE__->belongs_to(
  "post",
  "PearlBee::Model::Schema::Result::Post",
  { id => "post_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2014-02-04 12:34:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8/EPLmcxgc5p2iMf0l4kgw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
