package PearlBee::Profile;

=head1 PearlBee::Profile

Profile routes from the old PearlBee main file

=cut

use Dancer2 0.163000;
use Dancer2::Plugin::DBIC;

our $VERSION = '0.1';

=head2 Display profile page

=cut

get '/profile' => sub {

  template 'profile';

};

=head2 Display profile for a given author

=cut
  
get '/profile/author/:username' => sub {

  my $nr_of_rows = config->{blogs_on_page} || 5; # Number of posts per page
  my $username   = route_parameters->{'username'};
  my ( $user )   = resultset('Users')->search_lc( $username );
  unless ($user) {
    error "No such user '$username'";
  }
  my @blog_owners = resultset('BlogOwner')->search({ user_id => $user->id });
  my @blogs;
  for my $blog_owner ( @blog_owners ) {
    push @blogs, map { $_->as_hashref_sanitized }
                 resultset('Blog')->find({ id => $blog_owner->blog_id });
  }
  my @posts = resultset('Post')->search({ user_id => $user->id });
  my @post_tags;
  for my $post ( @posts ) {
    push @post_tags, map { $_->as_hashref_sanitized } $post->tag_objects;
  }
  for my $blog ( @blogs ) {
    $blog->{count} = {
      owners => 1,
      post   => scalar @posts,
      tag    => scalar @post_tags,
    };
    $blog->{post_tags} = \@post_tags;
  }

  my $template_data = {
      blogs      => \@blogs,
      blog_count => scalar @blogs,
      user       => $user->as_hashref_sanitized,
  }; 

  if ( param('format') ) {
    my $json = JSON->new;
    $json->allow_blessed(1);
    $json->convert_blessed(1);
    $json->encode( $template_data );
  }     
  else {
    template 'profile/author', $template_data;
  }

};

1;
