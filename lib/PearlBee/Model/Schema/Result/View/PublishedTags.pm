package PearlBee::Model::Schema::Result::View::PublishedTags;

# This view is used for grabbing all Tags which are assigned only to published posts

use strict;
use warnings;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');
__PACKAGE__->table('tag');
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(
    q[
      SELECT DISTINCT
        T.name, T.id, T.slug
        FROM
          tag AS T
        INNER JOIN
          post_tag AS PT ON PT.tag_id = T.id
        INNER JOIN
          post as P ON P.id = PT.post_id
        WHERE
            P.status = 'published'
    ]
);

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "slug",
  { data_type => "varchar", is_nullable => 1, size => 100 },
);
__PACKAGE__->set_primary_key("id");

sub as_hashref {
  my $self = shift;
  my $tag_href = {
    id   => $self->id,
    name => $self->name,
    slug => $self->slug,
  };     
              
  return $tag_href;
              
}             

sub as_hashref_sanitized {
  my $self = shift;
  my $published_tags_href = $self->as_hashref;
  delete $published_tags_href->{id};
  return $published_tags_href;
}

1;
