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
      	SUM( status = 'published' ) AS published,
      	SUM( status = 'trash') AS trash,
      	SUM( status = 'draft' ) AS draft,
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

sub get_all_status_counts {
  my $self = shift;

  return ( $self->total, $self->published, $self->draft, $self->trash );
}

sub get_status_count {
  my ($self, $status) = @_;

  return ( $status eq 'published' ) ? $self->published : ( $status eq 'trash' ) ? $self->trash : $self->draft;
}

1;