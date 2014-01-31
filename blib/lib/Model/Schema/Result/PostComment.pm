package Model::Schema::Result::PostComment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Model::Schema::Result::PostComment

=cut

__PACKAGE__->table("post_comment");

=head1 ACCESSORS

=head2 comment_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 post_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "comment_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "post_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("comment_id", "post_id");

=head1 RELATIONS

=head2 comment

Type: belongs_to

Related object: L<Model::Schema::Result::Comment>

=cut

__PACKAGE__->belongs_to(
  "comment",
  "Model::Schema::Result::Comment",
  { id => "comment_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 post

Type: belongs_to

Related object: L<Model::Schema::Result::Post>

=cut

__PACKAGE__->belongs_to(
  "post",
  "Model::Schema::Result::Post",
  { id => "post_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2014-01-08 21:41:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nMQFLTY+q0btnTjR3glISw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
