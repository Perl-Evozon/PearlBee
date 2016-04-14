package PearlBee::Author::Comment;

use Try::Tiny;
use Dancer2;
use Dancer2::Plugin::DBIC;

use PearlBee::Helpers::Pagination qw(get_total_pages get_previous_next_link generate_pagination_numbering);

=head2 /author/comments ; /author/comments/page/:page

List all comments

=cut

get '/author/comments' => sub { redirect '/author/comments/page/1'; };

get '/author/comments/page/:page' => sub {

  my $nr_of_rows = 5; # Number of posts per page
  my $page       = params->{page} || 1;
  my $user       = session('user');
  my $user_obj = resultset('Users')->search( {username=>$user->{username}} )->first;
  $user->{id}  = $user_obj->id;
  my @comments   = resultset('View::UserComments')->search({}, { bind => [ $user->{id} ], order_by => \"comment_date DESC", rows => $nr_of_rows, page => $page });
  my $count      = resultset('View::Count::StatusCommentAuthor')->search({}, { bind => [ $user->{id} ] })->first;
  my ($all, $approved, $trash, $spam, $pending) = $count->get_all_status_counts;

  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($all, $nr_of_rows);
  my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/author/comments');

  # Generating the pagination navigation
  my $total_comments = $all;
  my $posts_per_page = $nr_of_rows;
  my $current_page   = $page;
  my $pages_per_set  = 7;
  my $pagination     = generate_pagination_numbering($total_comments, $posts_per_page, $current_page, $pages_per_set);

  template 'admin/comments/list',
      {
        comments      => \@comments,
        all           => $all,
        approved      => $approved,
        spam          => $spam,
        pending       => $pending,
        trash         => $trash,
        page          => $page,
        next_link     => $next_link,
        previous_link => $previous_link,
        action_url    => 'author/comments/page',
        pages         => $pagination->pages_in_set
      },
      { layout => 'admin' };

};

=head2 /author/comments/:status/page/:page

List all comments grouped by status

=cut

get '/author/comments/:status/page/:page' => sub {

  my $nr_of_rows = 5; # Number of posts per page
  my $page       = params->{page} || 1;
  my $status     = params->{status};
  my $user       = session('user');
  $user          = resultset('Users')->find( $user->{id} );
  my @comments   = resultset('View::UserComments')->search({ status => $status },  { bind => [ $user->id ], order_by => \"comment_date DESC", rows => $nr_of_rows, page => $page });
  my $count       = resultset('View::Count::StatusCommentAuthor')->search({}, { bind => [ $user->id ] })->first;

  my ($all, $approved, $trash, $spam, $pending) = $count->get_all_status_counts;
  my $status_count                              = $count->get_status_count($status);

  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($all, $nr_of_rows);
  my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/author/comments/' . $status);

  # Generating the pagination navigation
  my $total_comments  = $status_count;
  my $posts_per_page  = $nr_of_rows;
  my $current_page    = $page;
  my $pages_per_set   = 7;
  my $pagination      = generate_pagination_numbering($total_comments, $posts_per_page, $current_page, $pages_per_set);

  template 'admin/comments/list',
      {
        comments      => \@comments,
        all           => $all,
        approved      => $approved,
        spam          => $spam,
        pending       => $pending,
        trash         => $trash,
        page          => $page,
        next_link     => $next_link,
        previous_link => $previous_link,
        action_url    => 'author/comments/' . $status . '/page',
        pages         => $pagination->pages_in_set
      },
      { layout => 'admin' };

};

=head2 /author/comments/approve/:id

Accept comment

=cut

get '/author/comments/approve/:id' => sub {

  my $comment_id = params->{id};
  my $comment    = resultset('Comment')->find( $comment_id );
  my $user       = session('user');

  try {
    $comment->approve($user);
  }
  catch {
    info $_;
    error "Could not approve comment for $user->{username}";
  };

  redirect '/author/comments';
};

=head2 /author/comments/trash/:id

Trash a comment

=cut

get '/author/comments/trash/:id' => sub {

  my $comment_id = params->{id};
  my $comment    = resultset('Comment')->find( $comment_id );
  my $user       = session('user');

  try {
    $comment->trash($user);
  }
  catch {
    info $_;
    error "Could not mark comment as trash for $user->{username}";
  };

  redirect '/author/comments';
};

=head2 /author/comments/spam/:id

Spam a comment

=cut

get '/author/comments/spam/:id' => sub {

  my $comment_id = params->{id};
  my $comment    = resultset('Comment')->find( $comment_id );
  my $user       = session('user');

  try {
    $comment->spam($user);
  }
  catch {
    info $_;
    error "Could not mark comment as spam for $user->{username}";
  };

  redirect '/author/comments';
};

=head2 /author/comments/pending/:id

Pending a comment

=cut

get '/author/comments/pending/:id' => sub {

  my $comment_id = params->{id};
  my $comment    = resultset('Comment')->find( $comment_id );
  my $user       = session('user');

  try {
    $comment->pending($user);
  }
  catch {
    info $_;
    error "Could not mark comment as pending for $user->{username}";
  };

  redirect '/author/comments';
};

1;
