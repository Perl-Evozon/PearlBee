use utf8;
package PearlBee::Model::Schema::Result::Post;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PearlBee::Model::Schema::Result::Post - Post table.

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';
use DateTime;
use DateTime::Format::MySQL;
use Date::Period::Human;

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
  is_nullable: 1
  size: 255

=head2 cover

  data_type: 'varchar'
  is_nullable: 0
  size: 300

=head2 content

  data_type: 'text'
  is_nullable: 0

=head2 content_more

  data_type: 'text'
  is_nullable: 0

=head2 created_date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 type

  data_type: 'enum'
  default_value: 'HTML'
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

__PACKAGE__->load_components(qw/InflateColumn::DateTime/);
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "title",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "slug",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "cover",
  { data_type => "varchar", is_nullable => 0, size => 300 },
  "content",
  { data_type => "text", is_nullable => 0 },
  "content_more",
  { data_type => "text", is_nullable => 0 },
  "created_date",
  {
    data_type => 'datetime',
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "type",
  { data_type => "enum", is_nullable => 0 },
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

Related object: L<PearlBee::Model::Schema::Result::Users>

=cut

__PACKAGE__->belongs_to(
  "user",
  "PearlBee::Model::Schema::Result::Users",
  { id => "user_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
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


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2015-02-23 16:54:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5V6erZKi9jLOYo38x62HWg


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

=head1 Check if the user has enough authorization for modifying

=cut

sub is_authorized {
  my ($self, $user) = @_;

  my $schema     = $self->result_source->schema;
  $user          = $schema->resultset('Users')->find( $user->{id} );
  my $authorized = 0;
  $authorized    = 1 if ( $user->is_admin );
  $authorized    = 1 if ( !$user->is_admin && $self->user_id == $user->id );

  return $authorized;
}

=head1 Return the tag

Check if the user has enough authorization for modifying

=cut

sub tag_objects {
  my ($self) = @_;
  my $schema = $self->result_source->schema;

  return map { $schema->resultset('Tag')->find({ id => $_->tag_id }) }
         $schema->resultset('PostTag')->search({ post_id => $self->id });
}

=head1 Return the category

=cut

sub category_objects {
  my ($self) = @_;
  my $schema = $self->result_source->schema;

  return map { $schema->resultset('Category')->find({ id => $_->category_id }) }
         $schema->resultset('PostCategory')->search({ post_id => $self->id });
}

=head1 Return the next post by this user in ID sequence, if any.

=cut

sub next_post {
  my ($self) = @_;
  my $schema = $self->result_source->schema;
  my @post   = $schema->resultset('Post')->search(
    { user_id => $self->user_id,
      id => { '>' => $self->id }
    },
    { rows => 1,
      order_by => { -asc => 'id' }
    }
  );
  return $post[0] || undef;
}

=head1 Return the previous post by this user in ID sequence, if any.

=cut

sub previous_post {
  my ($self) = @_;
  my $schema = $self->result_source->schema;
  my @post   = $schema->resultset('Post')->search(
    { user_id => $self->user_id,
      id => { '<' => $self->id }
    },
    { rows => 1,
      order_by => { -desc => 'id' }
    }
  );
  return $post[0] || undef;
}

sub created_date_human {

  my ($self) = @_;
  my $yesterday =
      DateTime->today( time_zone => 'UTC' )->subtract( days => 1 );
  if ( DateTime->compare( $self->created_date, $yesterday ) == 1 ) {
          my $dph = Date::Period::Human->new({ lang => 'en' });
          return $dph->human_readable( $self->created_date );
  }
  else {
          return $self->created_date->strftime('%b %d, %Y %l:%m%p');
  }
}

sub as_hashref {
  my ($self)   = @_;
  my $post_obj = {
    id           => $self->id,
    title        => $self->title,
    slug         => $self->slug,
    description  => $self->description,
    cover        => $self->cover,
    content      => $self->content,
    content_more => $self->content_more,
    created_date => $self->created_date,
    type         => $self->type,
    status       => $self->status,
    user_id      => $self->user_id,
  };          
              
  return $post_obj;
}             

sub as_hashref_sanitized {
  my ($self) = @_;
  my $href   = $self->as_hashref;

  delete $href->{id};
  delete $href->{user_id};
  return $href;
}

sub _massage_content {
  my ($self,$content) = @_;
  my $content = $self->content;
  my @content = split '\n', $content;
  
  my $in_pre = 0;
  for (@content) {
    $in_pre = 1 if m{<pre>};
    $in_pre = 0 if m{</pre>};
    next if $in_pre == 1;

    next if / ^ \s* $ /x;
    next if / ^ < /x;

    s{^}{<p>};
    s{$}{</p>};
  }

  return join "\n", @content;
}

sub massaged_content {
  my ($self)  = @_;
  return $self->_massage_content( $self->content );
}

sub massaged_content_more {
  my ($self)  = @_;
  return $self->_massage_content( $self->content_more );
}

1;
