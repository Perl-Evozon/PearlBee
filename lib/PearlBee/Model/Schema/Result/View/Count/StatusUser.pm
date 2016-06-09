package PearlBee::Model::Schema::Result::View::Count::StatusUser;

# This view is used for counting all stauts

use strict;
use warnings;
use base qw/DBIx::Class::Core/;

use Dancer2;
my $user_table = config->{ user_table };

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');
__PACKAGE__->table( $user_table );
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(
    qq[
      SELECT
      	SUM( CASE WHEN status = 'deactivated'  THEN 1 ELSE 0 END ) AS deactivated,
      	SUM( CASE WHEN status = 'activated'    THEN 1 ELSE 0 END ) AS activated,
      	SUM( CASE WHEN status = 'suspended' THEN 1 ELSE 0 END ) AS suspended,
        SUM( CASE WHEN status = 'pending'   THEN 1 ELSE 0 END ) AS pending,
      	COUNT(*) AS total
      FROM
      	$user_table
    ]
);

__PACKAGE__->add_columns(
  "deactivated",
  { data_type => "integer", is_nullable => 0 },
  "activated",
  { data_type => "integer", is_nullable => 0 },
  "suspended",
  { data_type => "integer", is_nullable => 0 },
  "pending",
  { data_type => "integer", is_nullable => 0 },
  "total",
  { data_type => "integer", is_nullable => 0 },
);

sub get_all_status_counts {
  my $self = shift;

  return ( $self->total, $self->activated, $self->deactivated, $self->suspended, $self->pending );
}

sub get_status_count {
  my ($self, $status) = @_;

  return ( $status eq 'activated' ) ? $self->activated : ( $status eq 'deactivated' ) ? $self->deactivated : ( $status eq 'suspended' ) ? $self->suspended : $self->pending;
}

1;
