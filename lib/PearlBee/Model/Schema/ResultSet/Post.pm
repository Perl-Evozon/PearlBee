package  PearlBee::Model::Schema::ResultSet::Post;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

use PearlBee::Helpers::Util qw/string_to_slug generate_new_slug_name/;

use String::Util qw(trim);

=head2 Create a new post

=cut

sub can_create {
  my ($self, $params) = @_;

  my $title   = $params->{title};
  my $slug    = $params->{slug};
  my $content = $params->{content};
  my $user_id = $params->{user_id};
  my $status  = $params->{status};
  my $cover   = $params->{cover};
  my $type    = $params->{type};

  my $post = $self->create_with_slug({
    title   => $title,
    content => $content,
    user_id => $user_id,
    status  => $status,
    cover   => $cover,
    type    => $type,
    slug    => $slug,
  });

  return $post;
}

=head2 Check if the slug is already used, if so generate a new slug or return the old one

=cut

sub check_slug {
	my ($self, $slug, $post_id) = @_;

	my $schema = $self->result_source->schema;
	$slug      = string_to_slug( $slug );

	my $found_slug 	 = $post_id
				? $schema->resultset('Post')->search({ id => { '!=' => $post_id }, slug => $slug })->first
				: $schema->resultset('Post')->find({ slug => $slug });
	my $slug_changed = 0;

	if ( $found_slug ) {
		# Extract the posts with slugs starting the same with the submited slug
		my @posts_with_same_slug = $schema->resultset('Post')->search({ slug => { like => "$slug%"}});
		my @slugs;
		push @slugs, $_->slug foreach @posts_with_same_slug;

		$slug = generate_new_slug_name($slug, \@slugs);
		$slug_changed = 1;
	}

	return ($slug, $slug_changed);
}

sub post_slug_exists {
	my ($self, $slug, $user_id) = @_;

	my $schema 	   	 = $self->result_source->schema;
	my $post 	     = $schema->resultset('Post')->search({ slug => $slug, user_id => $user_id })->first();

	return $post
}

=head2 Get the number of comments for this post

=cut

sub nr_of_comments {
  my ($self) = @_;

  my @post_comments = $self->comments;
  my @comments = grep { $_->status eq 'approved' } @post_comments;

  return scalar @comments;
}

=head2 Get all tags as a string sepparated by a comma

=cut

sub get_string_tags {
  my ($self) = @_;

  my @tag_names;
  my @post_tags = $self->post_tags;
  push( @tag_names, $_->tag->name ) foreach ( @post_tags );

  my $joined_tags = join(', ', @tag_names);

  return $joined_tags;
}

=head2 Status updates

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

=head2 Check if the user has enough authorization for modifying

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

sub get_recent_posts {
  my ($self) = @_;

  return $self->search({
  	status => 'published'
  	},{
  		order_by => {
  			-desc => "created_date"
  		}, rows => 3
	});
}

sub search_published {
  my ( $self, @args ) = @_;

  $args[0]{status} = 'published';
  return $self->search( @args );
}

=head2 Create post with internally-generated slug

=cut

sub create_with_slug {
  my ($self, $args) = @_;
  my $schema = $self->result_source->schema;
  my $slug   = string_to_slug( $args->{description} );
  $slug      = $args->{slug} if $args->{slug} and $args->{slug} ne '';

  $schema->resultset('Post')->create({
    title        => $args->{title},
    slug         => $slug,
    description  => $args->{description},
    cover        => $args->{cover},
    content      => $args->{content},
    content_more => $args->{content_more},
    type         => $args->{type},
    status       => $args->{status},
    user_id      => $args->{user_id},
  });
}

1;