package  PearlBee::Model::Schema::ResultSet::Category;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';
use PearlBee::Helpers::Util qw( string_to_slug );

=head2 Create category with internally-generated slug

=cut

sub create_with_slug {
  my ($self, $args) = @_;
  my $schema  = $self->result_source->schema;

  my $slug = string_to_slug( $args->{description} );

  $schema->resultset('Category')->create({
    name    => $args->{name},
    slug    => $slug,
    user_id => $args->{user_id}
  });
}

1;
