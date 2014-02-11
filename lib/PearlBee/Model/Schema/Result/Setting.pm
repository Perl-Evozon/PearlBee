package PearlBee::Model::Schema::Result::Setting;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

PearlBee::Model::Schema::Result::Setting

=cut

__PACKAGE__->table("settings");

=head1 ACCESSORS

=head2 timezone_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 social_media

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

=head2 blog_path

  data_type: 'varchar'
  default_value: '/'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "timezone_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "social_media",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "blog_path",
  { data_type => "varchar", default_value => "/", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("timezone_id", "social_media", "blog_path");

=head1 RELATIONS

=head2 timezone

Type: belongs_to

Related object: L<PearlBee::Model::Schema::Result::Timezone>

=cut

__PACKAGE__->belongs_to(
  "timezone",
  "PearlBee::Model::Schema::Result::Timezone",
  { id => "timezone_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2014-02-08 04:37:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jQSvJL6TvIjPr99+SZi5aQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
