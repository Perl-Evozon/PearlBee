package PearlBee::Model::Schema::Result::View::Count::StatusCommentAuthor;

# This view is used for grabbing comments per user

use strict;
use warnings;
use base qw/DBIx::Class::Core/;

use Dancer2;
my $user_table = config->{ user_table };

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');
__PACKAGE__->table('comment');
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(
    qq[
      SELECT
        SUM( C.status = 'pending' ) AS pending,
        SUM( C.status = 'approved') AS approved,
        SUM( C.status = 'trash' ) AS trash,
        SUM( C.status = 'spam' ) AS spam,
        COUNT(*) AS total
      FROM
        comment as C
        INNER JOIN
          post AS P
          ON
            P.id = C.post_id
        INNER JOIN $user_table AS U
          ON
            P.user_id = U.id
      WHERE
        U.id = ?
  ]
);

__PACKAGE__->add_columns(
  "pending",
  { data_type => "integer", is_nullable => 0 },
  "approved",
  { data_type => "integer", is_nullable => 0 },
  "trash",
  { data_type => "integer", is_nullable => 0 },
  "spam",
  { data_type => "integer", is_nullable => 0 },
  "total",
  { data_type => "integer", is_nullable => 0 },
);

sub get_all_status_counts {
  my $self = shift;

  return ( $self->total, $self->approved, $self->trash, $self->spam, $self->pending );
}

sub get_status_count {
  my ($self, $status) = @_;

  return ( $status eq 'pending' ) ? $self->pending : ( $status eq 'approved' ) ? $self->approved : ( $status eq 'trash' ) ? $self->trash : $self->spam;
}


1;
