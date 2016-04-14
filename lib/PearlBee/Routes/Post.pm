package PearlBee::Routes::Post;

=head1 PearlBee::Routes::Post

Post routes from the old PearlBee main file

=cut

use Dancer2 0.163000;
use Dancer2::Plugin::DBIC;
use PearlBee::Helpers::Util qw(map_posts);
use PearlBee::Helpers::Pagination qw(get_total_pages get_previous_next_link);

our $VERSION = '0.1';

=head2 /users/:username/:year/:month/:slug ; /post/:slug routes

View a given post

=cut

#http://blogs.perl.org/users/jt_smith/2016/03/tabletopevents-at-madmongers.html
#http://blogs.perl.org/users/jt_smith/2015/12/christmas-came-bah-humbug.html#comments

get '/users/:username/:year/:month/:slug' => sub {
  my $username = route_parameters->{'username'};
  my $year     = route_parameters->{'year'};
  my $month    = route_parameters->{'month'};
  my $slug     = route_parameters->{'slug'};

  redirect "/post/$slug"
};
 
get '/post/:slug' => sub {

  my $slug       = route_parameters->{'slug'};
  my $post       = resultset('Post')->find({ slug => $slug });
  my @tags       = map { $_->as_hashref_sanitized } $post->tag_objects;
  my @categories = map { $_->as_hashref_sanitized } $post->category_objects;

  session redirect => "/post/$slug";

  my ($next_post, $previous_post, @post_tags, @comments);
  if ( $post and $post->id ) {
    $next_post     = $post->next_post;
    $previous_post = $post->previous_post;
    @post_tags     = $post->tag_objects;
    @comments      = map { $_->as_hashref_sanitized }
                     resultset('Comment')->get_approved_comments_by_post_id($post->id);
  }

  template 'post', {
    post          => $post,
    next_post     => $next_post,
    previous_post => $previous_post,
    categories    => \@categories,
    comments      => \@comments,
    tags          => \@post_tags,
  };
};

=head2 /posts/category/:slug

View posts by category

=cut

get '/posts/category/:slug' => sub {

  my $slug     = route_parameters->{'slug'};
  my $category = resultset('Category')->find({ 'slug' => $slug });

  session redirect => "/posts/category/$slug";

  my $template_data;
  if ( $category ) {
    my $nr_of_rows   = config->{posts_on_page} || 5; # Number of posts per page
    my $page         = 1;
    my @posts        = resultset('Post')->search_published({ 'category.slug' => $slug }, { join => { 'post_categories' => 'category' }, order_by => { -desc => "created_date" }, rows => $nr_of_rows, page => $page });
    unless ( @posts ) {
      error "Could not find posts for slug '$slug'";
    }
    my $total_posts = resultset('Post')->search_published({ 'category.slug' => $slug }, { join => { 'post_categories' => 'category' } })->count;
    my @recent      = map { $_->as_hashref_sanitized }
                      resultset('Post')->search_published({},{ order_by => { -desc => "created_date" }, rows => 3 });
    my @popular     = map { $_->as_hashref_sanitized }
                      resultset('View::PopularPosts')->search({}, { rows => 3 });
    my @tags        = map { $_->as_hashref_sanitized }
                      map { $_->tag_objects } @posts;
    my @categories  = map { $_->as_hashref_sanitized }
                      map { $_->category_objects } @posts;
 
    # extract demo posts info
    my @mapped_posts = map_posts(@posts);
 
    # Calculate the next and previous page link
    my $total_pages                 = get_total_pages($total_posts, $nr_of_rows);
    my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/posts/category/' . $slug);
 
    # Extract all posts with the wanted category
    $template_data = {
      posts         => \@mapped_posts,
      recent        => \@recent,
      popular       => \@popular,
      tags          => \@tags,
      page          => $page,
      categories    => \@categories,
      total_pages   => $total_pages,
      next_link     => $next_link,
      previous_link => $previous_link,
      category      => $category->as_hashref_sanitized
    };
  }
  else {
    error "No category found for slug '$slug'";
  }

  if ( param('format') ) {
    my $json = JSON->new;
    $json->allow_blessed(1);
    $json->convert_blessed(1);
    $json->encode( $template_data );
  }     
  else {
    template 'index', $template_data;
  }
};

=head2 /posts/category/:slug/page/:page

View pages by category

=cut

get '/posts/category/:slug/page/:page' => sub {

  my $nr_of_rows  = config->{posts_on_page} || 10; # Number of posts per page
  my $page        = route_parameters->{'page'};
  my $slug        = route_parameters->{'slug'};
  my $category    = resultset('Category')->find({ 'slug' => $slug });
  my $template_data;

  session redirect => "/posts/category/$slug/page/$page";

  if ( $category ) {
    my $category_href = $category->as_hashref_sanitized;
    my @posts       = resultset('Post')->search_published({ 'category.slug' => $slug }, { join => { 'post_categories' => 'category' }, order_by => { -desc => "created_date" }, rows => $nr_of_rows, page => $page });
    my $nr_of_posts = resultset('Post')->search_published({ 'category.slug' => $slug }, { join => { 'post_categories' => 'category' } })->count;
    my @tags        = map { $_->as_hashref_sanitized }
                      map { $_->tag_objects } @posts;
    my @categories  = map { $_->as_hashref_sanitized }
                      map { $_->category_objects } @posts;
    my @recent      = map { $_->as_hashref_sanitized }
                      resultset('Post')->search_published({},{ order_by => { -desc => "created_date" }, rows => 3 });
    my @popular     = map { $_->as_hashref_sanitized }
                      resultset('View::PopularPosts')->search({}, { rows => 3 });
 
    # extract demo posts info
    my @mapped_posts = map_posts(@posts);
    my $movable_type_url = config->{movable_type_url};
    my $app_url = config->{app_url};
 
    for my $post ( @mapped_posts ) {
      $post->{content} =~ s{$movable_type_url}{$app_url}g;
    }
 
    # Calculate the next and previous page link
    my $total_pages                 = get_total_pages($nr_of_posts, $nr_of_rows);
    my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/posts/category/' . $slug);
 
    # Extract all posts with the wanted category
    $template_data =
      {
      posts         => \@mapped_posts,
      recent        => \@recent,
      popular       => \@popular,
      tags          => \@tags,
      categories    => \@categories,
      page          => $page,
      total_pages   => $total_pages,
      next_link     => $next_link,
      previous_link => $previous_link,
      category      => $category_href
      };
  }
  else {
    error "No category found for slug '$slug'";
  }

  if ( param('format') ) {
    my $json = JSON->new;
    $json->allow_blessed(1);
    $json->convert_blessed(1);
    $json->encode( $template_data );
  }
  else {
    template 'index', $template_data;
  }     

};

=head2 /posts/page/:page

Vew posts by username

=cut

get '/posts/page/:page' => sub {

  my $page        = route_parameters->{'page'};
  my $nr_of_rows  = config->{posts_on_page} || 10; # Number of posts per page
  my @posts       = resultset('Post')->search_published({},
                      { order_by => { -desc => "created_date" },
                        page => $page,
                        rows => $nr_of_rows });
  my $nr_of_posts = resultset('Post')->search_published()->count;
  my @recent      = resultset('Post')->search_published({},
                      { order_by => { -desc => "created_date" }, rows => 3 });
  my @popular     = resultset('View::PopularPosts')->search({}, { rows => 3 });
  my @tags        = map { $_->as_hashref_sanitized }
                    map { $_->tag_objects } @posts;
  my @categories  = map { $_->as_hashref_sanitized }
                    map { $_->category_objects } @posts;
  my $total_pages = get_total_pages($nr_of_posts, $nr_of_rows);

  # extract demo posts info
  my @mapped_posts     = map_posts(@posts);
  my $movable_type_url = config->{movable_type_url};
  my $app_url          = config->{app_url};

  session redirect => "/posts/page/$page";

  for my $post ( @mapped_posts ) {
    $post->{massaged_content}      =~ s{$movable_type_url}{$app_url}g;
    $post->{massaged_content_more} =~ s{$movable_type_url}{$app_url}g;
  }

  # Extract all posts with the wanted category
  my $template_data = {
    posts       => \@mapped_posts,
    recent      => \@recent,
    popular     => \@popular,
    tags        => \@tags,
    page        => $page,
    categories  => \@categories,
    total_pages => $total_pages,
  };

  if ( param('format') ) {
    my $json = JSON->new;
    $json->allow_blessed(1);
    $json->convert_blessed(1);
    $json->encode( $template_data );
  }
  else {
    template 'index', $template_data;
  }
};

=head2 /posts/user/:username

View posts by username

=cut

get '/posts/user/:username' => sub {

  my $nr_of_rows  = config->{posts_on_page} || 10; # Number of posts per page
  my $username    = route_parameters->{'username'};
  my ( $user )    = resultset('Users')->match_lc( $username );
  unless ($user) {
    error "No such user '$username'";
  }
  my @posts       = resultset('Post')->search_published({ 'user_id' => $user->id }, { order_by => { -desc => "created_date" }, rows => $nr_of_rows });
  my $nr_of_posts = resultset('Post')->search_published({ 'user_id' => $user->id })->count;
  my @recent      = resultset('Post')->search_published({},{ order_by => { -desc => "created_date" }, rows => 3 });
  my @popular     = resultset('View::PopularPosts')->search({}, { rows => 3 });
  my @tags        = map { $_->as_hashref_sanitized }
                    map { $_->tag_objects } @posts;
  my @categories  = map { $_->as_hashref_sanitized }
                    map { $_->category_objects } @posts;

  # extract demo posts info
  my @mapped_posts     = map_posts(@posts);
  my $movable_type_url = config->{movable_type_url};
  my $app_url          = config->{app_url};

  session redirect => "/posts/user/$username";

  for my $post ( @mapped_posts ) {
    $post->{content} =~ s{$movable_type_url}{$app_url}g;
  }

  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($nr_of_posts, $nr_of_rows);
  my ($previous_link, $next_link) = get_previous_next_link(1, $total_pages, '/posts/user/' . $username);

  # Extract all posts with the wanted category
  template 'index',
      {
        posts          => \@mapped_posts,
        recent         => \@recent,
        popular        => \@popular,
        tags           => \@tags,
        page           => 1,
        categories     => \@categories,
        total_pages    => $total_pages,
        next_link      => $next_link,
        previous_link  => $previous_link,
        posts_for_user => $username,
    };
};

=head2 /posts/user/:username/page/:page route

View posts for username by page

=cut

get '/posts/user/:username/page/:page' => sub {

  my $username    = route_parameters->{'username'};
  my $page        = route_parameters->{'page'};
  my $nr_of_rows  = config->{posts_on_page} || 5; # Number of posts per page
  my ( $user )    = resultset('Users')->match_lc( $username );
  unless ($user) {
    # we did not identify the user
    error "No such user '$username'";
  }
  my @posts       = resultset('Post')->search_published({ 'user_id' => $user->id }, { order_by => { -desc => "created_date" }, rows => $nr_of_rows, page => $page+1 });
  my $nr_of_posts = resultset('Post')->search_published({ 'user_id' => $user->id })->count;
  my @tags        = map { $_->as_hashref_sanitized }
                    map { $_->tag_objects } @posts;
  my @categories  = map { $_->as_hashref_sanitized }
                    map { $_->category_objects } @posts;

  # extract demo posts info
  my @mapped_posts = map_posts(@posts);

  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($nr_of_posts, $nr_of_rows);
  my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/posts/user/' . $username);

  session redirect => "/posts/user/$username/page/$page";

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
    template 'index', $template_data;
  }
};

=head2 /posts/tag/:slug

View posts by tag

=cut

get '/posts/tag/:slug' => sub {

  my $slug = route_parameters->{'slug'};
  my $tag  = resultset('Tag')->find({ slug => $slug });
  my $template_data;

  session redirect => "/posts/tag/$slug";

  if ( $tag ) {
    my $nr_of_rows  = config->{posts_on_page} || 5; # Number of posts per page
    my @posts = resultset('Post')->
                  search_published({ 'tag.slug' => $slug },
                                   { join => { 'post_tags' => 'tag' },
                                     order_by => { -desc => "created_date" },
                                     rows => $nr_of_rows });
    my $nr_of_posts = resultset('Post')->
                        search_published({ 'tag.slug' => $slug },
                                         { join => { 'post_tags' => 'tag' } })->                          count;
    my @recent      = map { $_->as_hashref_sanitized }
                      resultset('Post')->
                        search_published({}, { order_by =>
                                               { -desc => "created_date" },
                                               rows => 3 });
    my @popular     = map { $_->as_hashref_sanitized }
                      resultset('View::PopularPosts')->
                        search({}, { rows => 3 });
    my @tags        = map { $_->as_hashref_sanitized }
                      map { $_->tag_objects } @posts;
    my @categories  = map { $_->as_hashref_sanitized }
                      map { $_->category_objects } @posts;

    # extract demo posts info
    my @mapped_posts = map_posts(@posts);

    # Calculate the next and previous page link
    my $total_pages                 = get_total_pages($nr_of_posts, $nr_of_rows);
    my ($previous_link, $next_link) = get_previous_next_link(1, $total_pages, '/posts/tag/' . $slug);

    $template_data = {
      posts         => \@mapped_posts,
      recent        => \@recent,
      popular       => \@popular,
      tags          => \@tags,
      page          => 1,
      categories    => \@categories,
      total_pages   => $total_pages,
      next_link     => $next_link,
      previous_link => $previous_link,
      tag           => $tag->as_hashref_sanitized
    };
  }
  else {
    error "Could not find tag for slug '$slug'";
  }

  if ( param('format') ) {
    my $json = JSON->new;
    $json->allow_blessed(1);
    $json->convert_blessed(1);
    $json->encode( $template_data );
  }     
  else {
    template 'index', $template_data;
  }
};

=head2 /posts/tag/:slug/page/:page

View posts by tag by page

=cut

get '/posts/tag/:slug/page/:page' => sub {

  my $nr_of_rows  = config->{posts_on_page} || 10; # Number of posts per page
  my $slug        = route_parameters->{'slug'};
  my $page        = route_parameters->{'page'};
  my $tag         = resultset('Tag')->find({ slug => $slug });
  my @posts       = resultset('Post')->search_published({ 'tag.slug' => $slug }, { join => { 'post_tags' => 'tag' }, order_by => { -desc => "created_date" }, rows => $nr_of_rows, page => $page });
  my $nr_of_posts = resultset('Post')->search_published({ 'tag.slug' => $slug }, { join => { 'post_tags' => 'tag' } })->count;
  my @recent      = map { $_->as_hashref_sanitized }
                    resultset('Post')->search_published({},{ order_by => { -desc => "created_date" }, rows => 3 });
  my @popular     = map { $_->as_hashref_sanitized }
                    resultset('View::PopularPosts')->search({}, { rows => 3 });
  my @tags        = map { $_->as_hashref_sanitized }
                    map { $_->tag_objects } @posts;
  my @categories  = map { $_->as_hashref_sanitized }
                    map { $_->category_objects } @posts;

  # extract demo posts info
  my @mapped_posts     = map_posts(@posts);
  my $movable_type_url = config->{movable_type_url};
  my $app_url          = config->{app_url};

  session redirect => "/posts/tag/$slug/page/$page";

  for my $post ( @mapped_posts ) {
    $post->{content} =~ s{$movable_type_url}{$app_url}g;
  }

  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($nr_of_posts, $nr_of_rows);
  my ($previous_link, $next_link) = get_previous_next_link(1, $total_pages, '/posts/tag/' . $slug);

  # Extract all posts with the wanted category
  my $template_data =
      {
        posts          => \@mapped_posts,
        recent         => \@recent,
        popular        => \@popular,
        tags           => \@tags,
        page           => $page,
        categories     => \@categories,
        total_pages    => $total_pages,
        next_link      => $next_link,
        previous_link  => $previous_link,
#        posts_for_user => $username,
    };

  if ( param('format') ) {
    my $json = JSON->new;
    $json->allow_blessed(1);
    $json->convert_blessed(1);
    $json->encode( $template_data );
  }
  else {
    template 'index', $template_data;
  }     
};

1;
