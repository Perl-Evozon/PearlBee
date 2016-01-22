package  PearlBee::Model::Schema::ResultSet::Comment;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

use Gravatar::URL;
use DateTime;

use HTML::Strip;

sub can_create {
	my ($self, $params, $user) = @_;

	my $schema   = $self->result_source->schema;
	my $fullname = $params->{fullname};
	my $email    = $params->{email};
	my $website  = $params->{website} || '';
	my $text     = $params->{comment};
	my $post_id  = $params->{id};
	my $uid      = $params->{comment_as};

	# Grab the gravatar if exists, or a default image if not
	my $gravatar = gravatar_url(email => $email || '');

	# Filter the input data (avoid js injection)
	#
	my $hs = HTML::Strip->new();
	map { $_ = $hs->parse( $_ ); $hs->eof; } ($fullname, $text, $email, $website);

	$user 	 = $schema->resultset('User')->find( $user->{id} );
	my $post = $schema->resultset('Post')->find( $post_id );

	my $status = 'pending';
	$status = 'approved' if ($user && ( $user->is_admin || $user->id == $post->user->id ));

	my $comment = $self->create({
		fullname     => $fullname,
		content      => $text,
		email        => $email,
		website      => $website,
		avatar       => $gravatar,
		post_id      => $post_id,
		status       => $status,
		uid          => $uid,
		reply_to     => $params->{reply_to},
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
