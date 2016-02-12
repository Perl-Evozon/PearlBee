package PearlBee::Author::Comment;

use Dancer2;
use Dancer2::Plugin::DBIC;

use PearlBee::Helpers::Pagination qw(get_total_pages get_previous_next_link generate_pagination_numbering);

get '/author/comments' => sub { redirect session('app_url') . '/author/comments/page/1'; };

=head

List all comments

=cut

get '/author/comments/page/:page' => sub {

  my $nr_of_rows   = 5; # Number of posts per page
  my $page         = params->{page} || 1;
  my $user         = session('user');
  $user            = resultset('User')->find( $user->{id} );
  my @comments     = resultset('View::UserComments')->search({}, { bind => [ $user->id ], order_by => \"comment_date DESC", rows => $nr_of_rows, page => $page });
  my $count        = resultset('View::Count::StatusCommentAuthor')->search({}, { bind => [ $user->id ] })->first;

  my ($all, $approved, $trash, $spam, $pending) = $count->get_all_status_counts;

  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($all, $nr_of_rows);
  my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/author/comments');

  # Generating the pagination navigation
  my $total_comments  = $all;
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
        action_url    => 'author/comments/page',
        pages         => $pagination->pages_in_set
      },
      { layout => 'admin' };

};

=head

List all comments grouped by status

=cut

get '/author/comments/:status/page/:page' => sub {

  my $nr_of_rows  = 5; # Number of posts per page
  my $page        = params->{page} || 1;
  my $status      = params->{status};
  my $user        = session('user');
  $user           = resultset('User')->find( $user->{id} );
  my @comments    = resultset('View::UserComments')->search({ status => $status },  { bind => [ $user->id ], order_by => \"comment_date DESC", rows => $nr_of_rows, page => $page });
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

=head

Accept comment

=cut

get '/author/comments/approve/:id' => sub {

  my $comment_id = params->{id};
  my $comment    = resultset('Comment')->find( $comment_id );
  my $user       = session('user');

  eval { $comment->approve($user); };

  redirect session('app_url') . '/author/comments';
};

=haed

Trash a comment

=cut

get '/author/comments/trash/:id' => sub {

 my $comment_id  = params->{id};
  my $comment    = resultset('Comment')->find( $comment_id );
  my $user       = session('user');

  eval { $comment->trash($user); };

  redirect session('app_url') . '/author/comments';
};

=haed

Spam a comment

=cut

get '/author/comments/spam/:id' => sub {

  my $comment_id = params->{id};
  my $comment    = resultset('Comment')->find( $comment_id );
  my $user       = session('user');

  eval { $comment->spam($user); };

  redirect session('app_url') . '/author/comments';
};

=haed

Pending a comment

=cut

get '/author/comments/pending/:id' => sub {

  my $comment_id = params->{id};
  my $comment    = resultset('Comment')->find( $comment_id );
  my $user       = session('user');

  eval { $comment->pending($user); };

  redirect session('app_url') . '/author/comments';
};


1;
