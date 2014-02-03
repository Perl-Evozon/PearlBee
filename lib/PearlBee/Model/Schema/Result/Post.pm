package PearlBee::Model::Schema::Result::Post;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

PearlBee::Model::Schema::Result::Post

=cut

__PACKAGE__->table("post");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 title

  data_type: 'varchar'
  is_nullable: 0
  size: 200

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 cover

  data_type: 'varchar'
  is_nullable: 0
  size: 300

=head2 content

  data_type: 'text'
  is_nullable: 0

=head2 created_date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 status

  data_type: 'enum'
  default_value: 'draft'
  extra: {list => ["published","trash","draft"]}
  is_nullable: 1

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "title",
  { data_type => "varchar", is_nullable => 0, size => 200 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "cover",
  { data_type => "varchar", is_nullable => 0, size => 300 },
  "content",
  { data_type => "text", is_nullable => 0 },
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
    default_value => "draft",
    extra => { list => ["published", "trash", "draft"] },
    is_nullable => 1,
  },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 comments

Type: has_many

Related object: L<Model::Schema::Result::Comment>

=cut

__PACKAGE__->has_many(
  "comments",
  "Model::Schema::Result::Comment",
  { "foreign.post_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

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
  { "foreign.post_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 post_tags

Type: has_many

Related object: L<Model::Schema::Result::PostTag>

=cut

__PACKAGE__->has_many(
  "post_tags",
  "Model::Schema::Result::PostTag",
  { "foreign.post_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2014-01-27 14:32:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Yyy4JWqVvkqd9yEFN0A3tw


# You can replace this text with custom code or comments, and it will be preserved on regeneration

=head

Get the number of comments for this post

=cut

sub nr_of_comments {
  my ($self) = @_;

  my @post_comments = $self->comments;    
  my @comments = grep { $_->status eq 'approved' } @post_comments;

  return scalar @comments; 
}

=head 

Get all tags as a string sepparated by a comma

=cut

sub get_string_tags {
  my ($self) = @_;

  my @tag_names;
  my @post_tags = $self->post_tags;
  push( @tag_names, $_->tag->name ) foreach ( @post_tags );

  my $joined_tags = join(', ', @tag_names);

  return $joined_tags;
}

1;
