package  PearlBee::Model::Schema::ResultSet::Comment;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

use Gravatar::URL;
use DateTime;

sub can_create {
	my ($self, $params, $user) = @_;

	my $fullname = $params->{fullname};
	my $email    = $params->{email};
	my $website  = $params->{website} || '';
	my $text     = $params->{comment};
	my $post_id  = $params->{id};
	my $schema 	 = $self->result_source->schema;

	# Grab the gravatar if exists, or a default image if not
  	my $gravatar = gravatar_url(email => $email);

  	# Set the proper timezone
	my $dt       = DateTime->now;          
	my $settings = $schema->resultset('Setting')->first;
	my $dtf 	 = $schema->storage->datetime_parser;
	$dt->set_time_zone( $settings->timezone );

	# Filter the input data
    $fullname =~ s/[^a-zA-Z\d\s:]//g;
    $text     =~ s/[^a-zA-Z\d\s:]//g;
    $email    =~ s/[^a-zA-Z\d\s:]//g;
    $website  =~ s/[^a-zA-Z\d\s:]//g;

	$user 	 = $schema->resultset('User')->find( $user->{id} );
	my $post = $schema->resultset('Post')->find( $post_id );

	my $status = 'pending';
	$status    = ( $user->is_admin || $user->id == $post->user->id ) ? 'approved' : 'pending' if ($user);

	my $comment = $self->create({
          fullname     => $fullname,
          content      => $text,
          email        => $email,
          website      => $website,
          avatar       => $gravatar,
          post_id      => $post_id,
          status       => $status,
          comment_date => $dtf->format_datetime($dt)
    });

    return $comment;
}

1;