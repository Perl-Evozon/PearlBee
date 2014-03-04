package  PearlBee::Model::Schema::ResultSet::PostCategory;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

=head

Associate categories with the new post

=cut

sub connect_categories {
	my ($self, $categories, $post_id) = @_;

	$categories      	  ||= 1;                                             					 # If no category is selected the Uncategorized category will be stored default
    my @categories_selected = ref( $categories ) eq 'ARRAY' ? @{ $categories } : $categories;    # Force an array if only one category was selected

    # Delete any existing assocations [ For update ]
    my @post_categories = $self->search({ post_id => $post_id });
    $_->delete foreach (@post_categories);

	$self->create(
	{
	      category_id => $_,
	      post_id     => $post_id
	}) foreach ( @categories_selected );
}

1;