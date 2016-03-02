package  PearlBee::Model::Schema::ResultSet::Comment;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

use Gravatar::URL;
use DateTime;

use HTML::Strip;

sub can_create {
	my ($self, $params, $user) = @_;
	my $schema  = $self->result_source->schema;
	my $text    = $params->{comment};
	my $post_id = $params->{id};
	my $uid     = $params->{uid};
	my $post    = $schema->resultset('Post')->find( $post_id );
	my $status  = 'pending';

	# Filter the input data (avoid js injection)
	#
	my $hs = HTML::Strip->new();
        $text = $hs->parse( $text );

	$user 	 = $schema->resultset('Users')->find( $user->{id} );
	my $fullname = $user->name;
	my $email    = $user->email;

	$status = 'approved'
            if $user && ( $user->is_admin || $user->id == $post->user->id );

	# Let mySQL default to writing in UTC.
	#
	my $comment = $schema->resultset('Comment')->create({
		fullname => $fullname,
		content  => $text,
		email    => $email,
		post_id  => $post_id,
		status   => $status,
		uid      => $uid,
	});

	return $comment;
}


sub get_approved_comments_by_post_id {
    my ($self, $post_id) = @_;

    my @comments = $self->search(
        { post_id => $post_id,
      	  status => 'approved',
        },
        { order_by =>
          { -desc => "comment_date" }
        }
    );

    return @comments;

}

1;
