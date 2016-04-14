package  PearlBee::Model::Schema::ResultSet::PostTag;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

use String::Util qw(trim);

=head2 connect_tags

Associate categories with the new post

=cut

sub connect_tags {
	my ($self, $tags_string, $post_id) = @_;

	my @tags   = split( ',', $tags_string );
	my $schema = $self->result_source->schema;

	# Delete any tags associated with the post ( Used when update )
	my @post_tags = $self->search( { post_id => $post_id } );
    $_->delete foreach (@post_tags);

	foreach my $tag (@tags) {

		my $db_tag =
			$schema->resultset('Tag')->find_or_create_with_slug({ name => trim($tag) });

		$self->create({
		        tag_id  => $db_tag->id,
		        post_id => $post_id
		});
	}
}

1;