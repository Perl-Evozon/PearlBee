package  PearlBee::Model::Schema::ResultSet::PostMeta;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

sub get_meta_fields {
    # {
    #   name => 'the name to be displayed on the screen',
    #   key  => 'the db key of the metadata',
    #   type => 'the field type: text, checkbox, etc'
    # },

  return ();
}

sub update_meta_fields {
  my ( $self, $metadata, $post_id ) = @_;

  my @existing_keys = map { $_->{key} } get_meta_fields();

  foreach my $key ( @existing_keys ) {
    if ( $metadata->{ $key } ) {
      my $res = $self->update_or_create({
          post_id    => $post_id,
          meta_key   => $key,
          meta_value => $metadata->{ $key }
        });
    }
  }

}
1;