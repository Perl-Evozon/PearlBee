package PearlBee::Blogs;

=head1 PearlBee::Blog

Blog routes

=cut

use Dancer2 0.163000;
use Dancer2::Plugin::DBIC;
use PearlBee::Helpers::Util qw(map_posts);
use PearlBee::Helpers::Pagination qw(get_total_pages get_previous_next_link);

our $VERSION = '0.1';

=head2 View blog posts by username and blog slug

=cut

#http://139.162.204.109:5030/blogs/user/pmurias/slug/a_blog_about_the_perl_programming_language

get '/users/:username' => sub {
  my $username = route_parameters->{'username'};
  my $slug     = 'foo';

  redirect "/blogs/user/$username/slug/$slug"
};

get '/blogs/user/:username/slug/:slug' => sub {

  my $num_user_posts = config->{blogs}{user_posts} || 10;

  my $username    = route_parameters->{'username'};
  my ( $user )    = resultset('Users')->match_lc( $username );
  unless ($user) {
    error "No such user '$username'";
  }
  my @posts       = resultset('Post')->search_published({ 'user_id' => $user->id }, { order_by => { -desc => "created_date" }, rows => $num_user_posts });
  my $nr_of_posts = resultset('Post')->search_published({ 'user_id' => $user->id })->count;
  my @tags        = resultset('View::PublishedTags')->all();
  my @categories  = resultset('View::PublishedCategories')->search({ name => { '!=' => 'Uncategorized'} });

  # extract demo posts info
  my @mapped_posts = map_posts(@posts);
  my $movable_type_url = config->{movable_type_url};
  my $app_url = config->{app_url};

  for my $post ( @mapped_posts ) {
    $post->{content} =~ s{$movable_type_url}{$app_url}g;
  }

  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($nr_of_posts, $num_user_posts);
  my ($previous_link, $next_link) = get_previous_next_link(1, $total_pages, '/posts/user/' . $username);

 my @blog_owners = resultset('BlogOwner')->search({ user_id => $user->id });
    my @blogs;
    for my $blog_owner ( @blog_owners ) {
      push @blogs, map { $_->as_hashref_sanitized }
                   resultset('Blog')->find({ id => $blog_owner->blog_id });
    }

  # Extract all posts with the wanted category
  template 'blogs',
      {
        posts          => \@mapped_posts,
        tags           => \@tags,
        page           => 1,
        categories     => \@categories,
        total_pages    => $total_pages,
        next_link      => $next_link,
        previous_link  => $previous_link,
        posts_for_user => $username,
        blogs          => \@blogs,
        user           => $user
    };
};

=head View posts for username by page

=cut

get '/blogs/user/:username/slug/:slug/page/:page' => sub {

  my $num_user_posts = config->{blogs}{user_posts} || 10;

  my $username    = route_parameters->{'username'};
  my $page        = route_parameters->{'page'};
  my ( $user )    = resultset('Users')->match_lc( $username );
  unless ($user) {
    # we did not identify the user
    error "No such user '$username'";
  }
  my @posts       = resultset('Post')->search_published({ 'user_id' => $user->id }, { order_by => { -desc => "created_date" }, rows => $num_user_posts, page => $page });
  my $nr_of_posts = resultset('Post')->search_published({ 'user_id' => $user->id })->count;
  my @tags        = map { $_->as_hashref_sanitized }
                    map { $_->tag_objects } @posts;
  my @categories  = map { $_->as_hashref_sanitized }
                    map { $_->category_objects } @posts;

  # extract demo posts info
  my @mapped_posts = map_posts(@posts);

  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($nr_of_posts, $num_user_posts);
  my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/posts/user/' . $username);

  my $template_data =
    {
      posts          => \@mapped_posts,
      tags           => \@tags,
      categories     => \@categories,
      page           => $page,
      total_pages    => $total_pages,
      next_link      => $next_link,
      previous_link  => $previous_link,
      posts_for_user => $username,
    };
  if ( param('format') ) {
    my $json = JSON->new;
    $json->allow_blessed(1);
    $json->convert_blessed(1);
    $json->encode( $template_data );
  }
  else {
    template 'blogs', $template_data;
  }
};

1;
