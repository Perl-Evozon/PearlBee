package  PearlBee::Model::Schema::ResultSet::PostCategory;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';
use String::Util qw(trim);
use PearlBee::Helpers::Util qw/string_to_slug/;

=head

Associate categories with the new post

=cut

sub connect_categories {
    my ( $self, $categories, $post_id, $user_id ) = @_;

    $categories ||= 'Uncategorized';    # If no category is selected the Uncategorized category will be stored default

#    my @categories_selected = ref( $categories ) eq 'ARRAY' ? @{ $categories } : $categories;    # Force an array if only one category was selected
    my @categories_selected = split( ',', $categories );

    # Delete any existing assocations [ For update ]
    my @post_categories = $self->search( {post_id => $post_id} );
    $_->delete foreach (@post_categories);

    foreach my $category (@categories_selected) {
        my $slug = string_to_slug($category);

        my $db_category = $self->result_source->schema->resultset('Category')
            ->find_or_create( {name => trim($category), slug => $slug, user_id => $user_id} );

        $self->create(
            {   category_id => $db_category->id,
                post_id     => $post_id
            }
        );
    }

}

=head

Used in import

=cut

sub bind_categories {
    my ( $self, $categories, $post_id, $user_id ) = @_;

    $categories ||= 1;    # If no category is selected the Uncategorized category will be stored default
    my @categories_selected =
        ref($categories) eq 'ARRAY' ? @{$categories} : $categories;   # Force an array if only one category was selected

    # Delete any existing assocations [ For update ]
    my @post_categories = $self->search( {post_id => $post_id} );
    $_->delete foreach (@post_categories);

    foreach my $category (@categories_selected) {
        my $slug = string_to_slug($category);

        my $db_category = $self->result_source->schema->resultset('Category')
            ->find_or_create( {name => trim($category), slug => $slug, user_id => $user_id} );

        $self->create(
            {   category_id => $db_category->id,
                post_id     => $post_id
            }
        );
    }
}

1;
