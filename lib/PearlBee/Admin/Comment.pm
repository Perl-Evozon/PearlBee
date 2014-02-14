=head

Author: Andrei Cacio
Email: andrei.cacio@evozon.com

=cut

package PearlBee::Admin::Comment;

use Dancer2;
use Dancer2::Plugin::DBIC;

=head

List all comments

=cut

get '/admin/comments' => sub {

  my @comments   = resultset('Comment')->all;

  my $all     = scalar ( @comments );
  my $approved   = resultset('Comment')->search({ status => 'approved' })->count;
  my $trash     = resultset('Comment')->search({ status => 'trash' })->count;
  my $spam     = resultset('Comment')->search({ status => 'spam' })->count;
  my $pending   = resultset('Comment')->search({ status => 'pending' })->count;

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

get '/admin/comments/spam' => sub {

  my @comments = resultset('Comment')->search({ status => 'spam' }, { order_by => "comment_date DESC" });

  my $all     = resultset('Comment')->search({ 1 => '1'})->count;
  my $approved   = resultset('Comment')->search({ status => 'approved' })->count;
  my $trash     = resultset('Comment')->search({ status => 'trash' })->count;
  my $spam     = resultset('Comment')->search({ status => 'spam' })->count;
  my $pending   = resultset('Comment')->search({ status => 'pending' })->count;

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

get '/admin/comments/trash' => sub {

  my @comments = resultset('Comment')->search({ status => 'trash' }, { order_by => "comment_date DESC" });

  my $all     = resultset('Comment')->search({ 1 => '1'})->count;
  my $approved   = resultset('Comment')->search({ status => 'approved' })->count;
  my $trash     = resultset('Comment')->search({ status => 'trash' })->count;
  my $spam     = resultset('Comment')->search({ status => 'spam' })->count;
  my $pending   = resultset('Comment')->search({ status => 'pending' })->count;

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

get '/admin/comments/pending' => sub {

  my @comments = resultset('Comment')->search({ status => 'pending' }, { order_by => "comment_date DESC" });

  my $all     = resultset('Comment')->search({ 1 => '1'})->count;
  my $approved   = resultset('Comment')->search({ status => 'approved' })->count;
  my $trash     = resultset('Comment')->search({ status => 'trash' })->count;
  my $spam     = resultset('Comment')->search({ status => 'spam' })->count;
  my $pending   = resultset('Comment')->search({ status => 'pending' })->count;

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

get '/admin/comments/approved' => sub {

  my @comments = resultset('Comment')->search({ status => 'approved' }, { order_by => "comment_date DESC" });

  my $all     = resultset('Comment')->search({ 1 => '1'})->count;
  my $approved   = resultset('Comment')->search({ status => 'approved' })->count;
  my $trash     = resultset('Comment')->search({ status => 'trash' })->count;
  my $spam     = resultset('Comment')->search({ status => 'spam' })->count;
  my $pending   = resultset('Comment')->search({ status => 'pending' })->count;

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

get '/admin/comments/approve/:id' => sub {

  my $comment_id = params->{id};
  my $comment = resultset('Comment')->find( $comment_id );

  eval {
    $comment->update({
        status => 'approved'
      });
  };

  redirect session('app_url') . '/admin/comments';
};

=haed

Trash a comment

=cut

get '/admin/comments/trash/:id' => sub {

  my $comment_id = params->{id};
  my $comment = resultset('Comment')->find( $comment_id );

  eval {
    $comment->update({
        status => 'trash'
      });
  };

  redirect session('app_url') . '/admin/comments';
};

=haed

Spam a comment

=cut

get '/admin/comments/spam/:id' => sub {

  my $comment_id = params->{id};
  my $comment = resultset('Comment')->find( $comment_id );

  eval {
    $comment->update({
        status => 'spam'
      });
  };

  redirect session('app_url') . '/admin/comments';
};

=haed

Pending a comment

=cut

get '/admin/comments/pending/:id' => sub {

  my $comment_id = params->{id};
  my $comment = resultset('Comment')->find( $comment_id );

  eval {
    $comment->update({
        status => 'pending'
      });
  };

  redirect session('app_url') . '/admin/comments';
};


1;