package  PearlBee::Model::Schema::ResultSet::Tag;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

=head2 Search for a tag case-insensitive

=cut

sub search_lc {
  my ($self, $tag) = @_;
  my $schema            = $self->result_source->schema;
  
  my $lc_tag = lc $tag; 
  return $schema->resultset('Tag')->
                  search( \[ "lower(name) like '\%$lc_tag\%'" ] );
}

1;
