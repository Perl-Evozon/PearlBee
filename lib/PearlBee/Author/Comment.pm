package PearlBee::Author::Comment;

use Dancer2;
use Dancer2::Plugin::DBIC;

=head

List all comments

=cut

get '/author/comments' => sub {

  my $user     = session('user');
  my @comments   = resultset('View::UserComments')->search({}, { bind => [ $user->id ] });

  my $all     = scalar ( @comments );
  my $approved   = resultset('View::UserComments')->search({ status => 'approved' }, { bind => [ $user->id ] })->count;
  my $trash     = resultset('View::UserComments')->search({ status => 'trash' }, { bind => [ $user->id ] })->count;
  my $spam     = resultset('View::UserComments')->search({ status => 'spam' }, { bind => [ $user->id ] })->count;
  my $pending   = resultset('View::UserComments')->search({ status => 'pending' }, { bind => [ $user->id ] })->count;

  template '/admin/comments/list',
      {
        comments => \@comments,
        all    => $all,
        approved => $approved,
        spam    => $spam,
        pending  => $pending,
        trash    => $trash
      },
      { layout => 'admin' };

};

=head

List all spam comments

=cut

get '/author/comments/spam' => sub {

  my $user     = session('user');
  my @comments   = resultset('View::UserComments')->search({ status => 'spam' }, { order_by => "comment_date DESC", bind => [ $user->id ] });

  my $all     = resultset('View::UserComments')->search({}, { bind => [ $user->id ] })->count;
  my $approved   = resultset('View::UserComments')->search({ status => 'approved' }, { bind => [ $user->id ] })->count;
  my $trash     = resultset('View::UserComments')->search({ status => 'trash' }, { bind => [ $user->id ] })->count;
  my $spam     = scalar( @comments );
  my $pending   = resultset('View::UserComments')->search({ status => 'pending' }, { bind => [ $user->id ] })->count;

  template '/admin/comments/list',
      {
        comments => \@comments,
        all    => $all,
        approved => $approved,
        spam    => $spam,
        pending  => $pending,
        trash    => $trash
      },
      { layout => 'admin' };

};

=head

List all trash comments

=cut

get '/author/comments/trash' => sub {

  my $user     = session('user');
  my @comments   = resultset('View::UserComments')->search({ status => 'trash' }, { order_by => "comment_date DESC", bind => [ $user->id ] });

  my $all     = resultset('View::UserComments')->search({}, { bind => [ $user->id ] })->count;
  my $approved   = resultset('View::UserComments')->search({ status => 'approved' }, { bind => [ $user->id ] })->count;
  my $trash     = scalar( @comments );
  my $spam     = resultset('View::UserComments')->search({ status => 'spam' }, { bind => [ $user->id ] })->count;
  my $pending   = resultset('View::UserComments')->search({ status => 'pending' }, { bind => [ $user->id ] })->count;

  template '/admin/comments/list',
      {
        comments => \@comments,
        all    => $all,
        approved => $approved,
        spam    => $spam,
        pending  => $pending,
        trash    => $trash
      },
      { layout => 'admin' };

};

=head

List all pending comments

=cut

get '/author/comments/pending' => sub {

  my $user     = session('user');
  my @comments   = resultset('Comment')->search({ status => 'pending' }, { order_by => "comment_date DESC" });

  my $all     = resultset('View::UserComments')->search({}, { bind => [ $user->id ] })->count;
  my $approved   = resultset('View::UserComments')->search({ status => 'approved' }, { bind => [ $user->id ] })->count;
  my $trash     = resultset('View::UserComments')->search({ status => 'trash' }, { bind => [ $user->id ] })->count;
  my $spam     = resultset('View::UserComments')->search({ status => 'spam' }, { bind => [ $user->id ] })->count;
  my $pending   = scalar( @comments );

  template '/admin/comments/list',
      {
        comments => \@comments,
        all    => $all,
        approved => $approved,
        spam    => $spam,
        pending  => $pending,
        trash    => $trash
      },
      { layout => 'admin' };

};

=head

List all approved comments

=cut

get '/author/comments/approved' => sub {

  my $user     = session('user');
  my @comments   = resultset('View::UserComments')->search({ status => 'approved' }, { order_by => "comment_date DESC", bind => [ $user->id ] });

  my $all     = resultset('View::UserComments')->search({}, { bind => [ $user->id ] })->count;
  my $approved   = scalar ( @comments );
  my $trash     = resultset('View::UserComments')->search({ status => 'trash' }, { bind => [ $user->id ] })->count;
  my $spam     = resultset('View::UserComments')->search({ status => 'spam' }, { bind => [ $user->id ] })->count;
  my $pending   = resultset('View::UserComments')->search({ status => 'pending' }, { bind => [ $user->id ] })->count;

  template '/admin/comments/list',
      {
        comments => \@comments,
        all    => $all,
        approved => $approved,
        spam    => $spam,
        pending  => $pending,
        trash    => $trash
      },
      { layout => 'admin' };

};

=head

Accept comment

=cut

get '/author/comments/approve/:id' => sub {

  my $comment_id = params->{id};
  my $comment = resultset('Comment')->find( $comment_id );

  eval {
    $comment->update({
        status => 'approved'
      });
  };

  redirect '/author/comments';
};

=haed

Trash a comment

=cut

get '/author/comments/trash/:id' => sub {

  my $comment_id = params->{id};
  my $comment = resultset('Comment')->find( $comment_id );

  eval {
    $comment->update({
        status => 'trash'
      });
  };

  redirect '/author/comments';
};

=haed

Spam a comment

=cut

get '/author/comments/spam/:id' => sub {

  my $comment_id = params->{id};
  my $comment = resultset('Comment')->find( $comment_id );

  eval {
    $comment->update({
        status => 'spam'
      });
  };

  redirect '/author/comments';
};

=haed

Pending a comment

=cut

get '/author/comments/pending/:id' => sub {

  my $comment_id = params->{id};
  my $comment = resultset('Comment')->find( $comment_id );

  eval {
    $comment->update({
        status => 'pending'
      });
  };

  redirect '/author/comments';
};


1;