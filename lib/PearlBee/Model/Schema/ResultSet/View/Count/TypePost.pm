package  PearlBee::Model::Schema::ResultSet::View::Count::TypePost;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

sub get_all_status_counts {
  my ($self, $post_type) = @_;


  my $count = $self->search( { post_type => $post_type } )->first;

  if ( $count ) {
    return ( $count->total, $count->published, $count->draft, $count->trash );
  } else {
    return ( 0, 0, 0, 0 );
  }
}

sub get_status_count {
  my ($self, $status, $post_type) = @_;

  my $count = $self->search( { post_type => $post_type } )->first;

  if ( $count ) {
	  return ( $status eq 'published' ) ? $count->published : ( $status eq 'trash' ) ? $count->trash : $count->draft;
  } else {
  	return 0;
  }
}


1;