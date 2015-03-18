use utf8;
package PearlBee::Model::Schema::Result::Setting;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PearlBee::Model::Schema::Result::Setting - Settings table.

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<settings>

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

=head2 multiuser

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 id

  data_type: 'integer'
  is_nullable: 0

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
  "multiuser",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "id",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2015-03-02 17:05:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pPDcwMO6XscnOSKbOwKgBA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
