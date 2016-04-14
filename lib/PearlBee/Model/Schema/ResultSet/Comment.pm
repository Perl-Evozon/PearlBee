package  PearlBee::Model::Schema::ResultSet::Comment;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

use HTML::Scrubber::StripScripts;

use utf8;

=head2 can_create

=cut

sub can_create {
	my ($self, $params, $user) = @_;
	my $schema  = $self->result_source->schema;
	my $text    = $params->{comment};
	#The is_utf8 method does not return true.
	#As a consequence, we need to decode the content so that the database will not contain spurious data.
	utf8::decode($text);
	my $post_id = $params->{id};
	my $uid     = $params->{uid};
	my $post    = $schema->resultset('Post')->find( $post_id );
	my $status  = 'pending';

	# Filter the input data (avoid js injection)
	#
	my $hs = HTML::Scrubber::StripScripts->new(
		Allow_src      => 1,
		Allow_href     => 1,
		Allow_a_mailto => 1,
		Whole_document => 1,
		Block_tags     => ['hr'],
	);
	$text = $hs->scrub( $text );
	$user = $schema->resultset('Users')->find( $user->{id} );


	my $fullname = $user->name;
	my $email    = $user->email;

	$status = 'approved'
            if $user && ( $user->is_admin || $user->id == $post->user->id );

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

=head2 get_approved_comments_by_post_id

=cut

sub get_approved_comments_by_post_id {
	my ($self, $post_id) = @_;

	my @comments = $self->search(
		{ post_id => $post_id,
		  status  => 'approved',
		},
		{ order_by => { -desc => "comment_date" } }
	);

	return @comments;
}

1;
