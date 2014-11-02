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

=head2 timezone

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 social_media

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

=head2 blog_path

  data_type: 'varchar'
  default_value: '/'
  is_nullable: 0
  size: 255

=head2 theme_folder

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 blog_name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "timezone",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "social_media",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "blog_path",
  { data_type => "varchar", default_value => "/", is_nullable => 0, size => 255 },
  "theme_folder",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "blog_name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("timezone", "social_media", "blog_path");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2014-03-06 16:50:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:w62Hs9dC9yPBqU3YHClvKQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
