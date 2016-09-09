use utf8;
package PearlBee::Model::Schema::Result::Post;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PearlBee::Model::Schema::Result::Post

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<post>

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
  size: 255

=head2 slug

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 description

  data_type: 'varchar'
  default_value: null
  is_nullable: 1
  size: 255

=head2 cover

  data_type: 'varchar'
  is_nullable: 0
  size: 300

=head2 content

  data_type: 'text'
  is_nullable: 0

=head2 created_date

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0

=head2 status

  data_type: 'text'
  default_value: 'draft'
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
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "slug",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "description",
  {
    data_type => "varchar",
    default_value => \"null",
    is_nullable => 1,
    size => 255,
  },
  "cover",
  { data_type => "varchar", is_nullable => 0, size => 300 },
  "content",
  { data_type => "text", is_nullable => 0 },
  "created_date",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "status",
  { data_type => "text", default_value => "draft", is_nullable => 1 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 comments

Type: has_many

Related object: L<PearlBee::Model::Schema::Result::Comment>

=cut

__PACKAGE__->has_many(
  "comments",
  "PearlBee::Model::Schema::Result::Comment",
  { "foreign.post_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 post_categories

Type: has_many

Related object: L<PearlBee::Model::Schema::Result::PostCategory>

=cut

__PACKAGE__->has_many(
  "post_categories",
  "PearlBee::Model::Schema::Result::PostCategory",
  { "foreign.post_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 post_tags

Type: has_many

Related object: L<PearlBee::Model::Schema::Result::PostTag>

=cut

__PACKAGE__->has_many(
  "post_tags",
  "PearlBee::Model::Schema::Result::PostTag",
  { "foreign.post_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user

Type: belongs_to

Related object: L<PearlBee::Model::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "PearlBee::Model::Schema::Result::User",
  { id => "user_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 categories

Type: many_to_many

Composing rels: L</post_categories> -> category

=cut

__PACKAGE__->many_to_many("categories", "post_categories", "category");

=head2 tags

Type: many_to_many

Composing rels: L</post_tags> -> tag

=cut

__PACKAGE__->many_to_many("tags", "post_tags", "tag");


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-09-09 16:21:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ik9zhzmJvvgKxubopNAZog


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->load_components(qw/UTF8Columns/);
__PACKAGE__->utf8_columns(qw/title content/);

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

=head 
Status updates
=cut

sub publish {
  my ($self, $user) = @_;

  $self->update({ status => 'published' }) if ( $self->is_authorized( $user ) );
}

sub draft {
  my ($self, $user) = @_;

  $self->update({ status => 'draft' }) if ( $self->is_authorized( $user ) );
}


sub trash {
  my ($self, $user) = @_;

  $self->update({ status => 'trash' }) if ( $self->is_authorized( $user ) );
}

=haed
Check if the user has enough authorization for modifying
=cut

sub is_authorized {
  my ($self, $user) = @_;

  my $schema     = $self->result_source->schema;
  $user          = $schema->resultset('User')->find( $user->{id} );
  my $authorized = 0;
  $authorized    = 1 if ( $user->is_admin );
  $authorized    = 1 if ( !$user->is_admin && $self->user_id == $user->id );

  return $authorized;
}

1;
