package  PearlBee::Model::Schema::ResultSet::Tag;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';
use PearlBee::Helpers::Util qw( string_to_slug );

=head2 Search for a tag case-insensitive

=cut

sub search_lc {
  my ($self, $tag) = @_;
  my $schema = $self->result_source->schema;
  my $lc_tag = lc $tag; 
  return $schema->resultset('Tag')->
                  search( \[ "lower(name) like '\%$lc_tag\%'" ] );
}

=head2 Find or create tag with internally-generated slug

=cut

sub find_or_create_with_slug {
  my ($self, $args) = @_;
  my $schema = $self->result_source->schema;
  my $slug   = string_to_slug( $args->{name} );
  $slug      = $args->{slug} if $args->{slug} and $args->{slug} ne '';

  return $schema->resultset('Tag')->find_or_create({
    name => $args->{name},
    slug => $slug,
  });
}

=head2 Create tag with internally-generated slug

=cut

sub create_with_slug {
  my ($self, $args) = @_;
  my $schema = $self->result_source->schema;
  my $slug   = string_to_slug( $args->{description} );
  $slug      = $args->{slug} if $args->{slug} and $args->{slug} ne '';

  $schema->resultset('Tag')->create({
    name => $args->{name},
    slug => $slug,
  });
}

1;
