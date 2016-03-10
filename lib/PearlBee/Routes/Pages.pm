package PearlBee::Routes::Pages;

use Dancer2 0.163000;
use Dancer2::Plugin::DBIC;
use PearlBee::Helpers::Util qw(map_pages);
use PearlBee::Helpers::Pagination qw(get_total_pages get_previous_next_link);

our $VERSION = '0.1';

# Internal note here - Keep the Routes/ directory clean of little "handlers".
# Given the history of the application anything added here will be replicated
# all over h*ll.

=head2 View a given page

=cut

get '/pages/:slug' => sub {

  my $slug = route_parameters->{'slug'};
  my $page = resultset('Page')->find({ slug => $slug });

  unless ( $page ) {
    error "No page found by that slug";
    return;
  }

  my @tags       = map { $_->as_hashref_sanitized } $page->tag_objects;
  my @categories = map { $_->as_hashref_sanitized } $page->category_objects;

  my ($next_page, $previous_page, @page_tags, @comments);
  if ( $page and $page->id ) {
    $next_page     = $page->next_page;
    $previous_page = $page->previous_page;
    @page_tags     = $page->tag_objects;
    @comments      = map { $_->as_hashref }
                     resultset('Comment')->get_approved_comments_by_page_id($page->id);
  }

  template 'pages', {
    page          => $page,
    next_page     => $next_page,
    previous_page => $previous_page,
    categories    => \@categories,
    comments      => \@comments,
    tags          => \@page_tags,
  };
};

=head2 View page by username

=cut

get '/pages/user/:username' => sub {

  my $nr_of_rows = config->{pages_on_page} || 10;
  my $username   = route_parameters->{'username'};
  my ( $user )   =
    resultset('Users')->search( \[ 'lower(username) = ?' => lc $username ] );

  unless ($user) {
    error "No such user '$username'";
  }

  my @pages       = resultset('Page')->search_published({ 'user_id' => $user->id }, { order_by => { -desc => "created_date" }, rows => $nr_of_rows });
  my $nr_of_pages = resultset('Page')->search_published({ 'user_id' => $user->id })->count;
  my @tags        = map { $_->as_hashref_sanitized }
                    map { $_->tag_objects } @pages;
  my @categories  = map { $_->as_hashref_sanitized }
                    map { $_->category_objects } @pages;

  my @mapped_pages = map_pages(@pages);
  my $movable_type_url = config->{movable_type_url};
  my $app_url = config->{app_url};

  for my $page ( @mapped_pages ) {
    $page->{content} =~ s{$movable_type_url}{$app_url}g;
  }


  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($nr_of_pages, $nr_of_rows);
  my ($previous_link, $next_link) = get_previous_next_link(1, $total_pages, '/page/user/' . $username);

  template 'pages', {
    pages          => \@mapped_pages,
    tags           => \@tags,
    page           => 1,
    categories     => \@categories,
    total_pages    => $total_pages,
    next_link      => $next_link,
    previous_link  => $previous_link,
    pages_for_user => $username,
  };
};

=head2 View pages for username by page

=cut

get '/pages/user/:username/page/:page' => sub {

  my $username    = route_parameters->{'username'};
  my $page        = route_parameters->{'page'};
  my $nr_of_rows  = config->{pages_on_page} || 5;
  my ( $user )    =
    resultset('Users')->search( \[ 'lower(username) = ?' => lc $username ] );
  unless ($user) {
    # we did not identify the user
    error "No such user '$username'";
  }
  my @pages       = resultset('Page')->search_published({ 'user_id' => $user->id }, { order_by => { -desc => "created_date" }, rows => $nr_of_rows, page => $page });
  my $nr_of_pages = resultset('Page')->search_published({ 'user_id' => $user->id })->count;
  my @tags        = map { $_->as_hashref_sanitized }
                    map { $_->tag_objects } @pages;
  my @categories  = map { $_->as_hashref_sanitized }
                    map { $_->category_objects } @pages;

  my @mapped_pages = map_pages(@pages);

  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($nr_of_pages, $nr_of_rows);
  my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/pages/user/' . $username);

  my $template_data = {
    pages          => \@mapped_pages,
    tags           => \@tags,
    categories     => \@categories,
    page           => $page,
    total_pages    => $total_pages,
    next_link      => $next_link,
    previous_link  => $previous_link,
    pages_for_user => $username,
  };

  if ( param('format') ) {
    my $json = JSON->new;
    $json->allow_blessed(1);
    $json->convert_blessed(1);
    $json->encode( $template_data );
  }
  else {
    template 'pages', $template_data;
  }
};

=head2 View pages by username

=cut

get '/pages/page/:page' => sub {

  my $nr_of_rows  = config->{pages_on_page} || 10;
  my @pages       = resultset('Page')->search_published({},
                      { order_by => { -desc => "created_date" },
                        rows => $nr_of_rows });
  my $nr_of_pages = resultset('Page')->search_published()->count;
  my @tags        = map { $_->as_hashref_sanitized }
                    map { $_->tag_objects } @pages;
  my @categories  = map { $_->as_hashref_sanitized }
                    map { $_->category_objects } @pages;

  my @mapped_pages = map_pages(@pages);
  my $movable_type_url = config->{movable_type_url};
  my $app_url = config->{app_url};

  for my $page ( @mapped_pages ) {
    $page->{content} =~ s{$movable_type_url}{$app_url}g;
  }

  # Calculate the next and previous page link
  my $total_pages = get_total_pages($nr_of_pages, $nr_of_rows);

  # Extract all pages with the wanted category
  my $template_data = {
    pages       => \@mapped_pages,
    tags        => \@tags,
    page        => 1,
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
    template 'page', $template_data;
  }
};

1;
