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

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 timezone

  data_type: 'varchar'
  is_nullable: 0
  size: 200

=cut

__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "timezone",
  { data_type => "varchar", is_nullable => 0, size => 200 },
);
__PACKAGE__->set_primary_key("user_id");

=head1 RELATIONS

=head2 user

Type: belongs_to

Related object: L<Model::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Model::Schema::Result::User",
  { id => "user_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2014-01-20 11:27:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Z/hCtn7dtRQ5klO++DNKiA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
