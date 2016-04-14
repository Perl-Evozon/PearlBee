package PearlBee::Model::Schema::Result::View::Count::StatusPost;

# This view is used for counting all stauts

use strict;
use warnings;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');
__PACKAGE__->table('post');
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(
    q[
      SELECT
      	SUM( CASE WHEN status = 'published' THEN 1 ELSE 0 END ) AS published,
      	SUM( CASE WHEN status = 'trash' THEN 1 ELSE 0 END ) AS trash,
      	SUM( CASE WHEN status = 'draft' THEN 1 ELSE 0 END ) AS draft,
      	COUNT(*) AS total
      FROM
      	post
    ]
);

__PACKAGE__->add_columns(
  "published",
  { data_type => "integer", is_nullable => 0 },
  "trash",
  { data_type => "integer", is_nullable => 0 },
  "draft",
  { data_type => "integer", is_nullable => 0 },
  "total",
  { data_type => "integer", is_nullable => 0 },
);

=head2 get_all_status_counts

=cut

sub get_all_status_counts {
  my ($self) = @_;

  return ( $self->total, $self->published, $self->draft, $self->trash );
}

=head2 get_status_count

=cut

sub get_status_count {
  my ($self, $status) = @_;

  return ( $status eq 'published' ) ? $self->published : ( $status eq 'trash' ) ? $self->trash : $self->draft;
}

1;
