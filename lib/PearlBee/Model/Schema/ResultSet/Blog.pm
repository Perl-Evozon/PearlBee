package  PearlBee::Model::Schema::ResultSet::Blog;

use strict;
use warnings;

use Dancer2;
use Dancer2::Plugin::DBIC;
use PearlBee::Model::Schema;
use PearlBee::Helpers::Util qw( string_to_slug );
use base 'DBIx::Class::ResultSet';

=head2 create_with_slug

Create blog with internally-generated slug

=cut

sub create_with_slug {
  my ($self, $args) = @_;
  my $schema = $self->result_source->schema;
  my $slug   = string_to_slug( $args->{description} );
  $slug      = $args->{slug} if $args->{slug} and $args->{slug} ne '';

  $schema->resultset('Blog')->create({
    name        => $args->{name},
    description => $args->{description},
    slug        => $slug,
  });
}

1;
