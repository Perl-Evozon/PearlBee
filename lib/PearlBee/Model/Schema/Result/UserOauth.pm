use utf8;
package PearlBee::Model::Schema::Result::UserOauth;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PearlBee::Model::Schema::Result::UserOauth - User OAuth service IDs

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<user_oauth>

=cut

__PACKAGE__->table("user_oauth");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 service

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 255

=head2 service_id

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "service",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 255 },
  "service_id",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</user_id>

=item * L</service>

=item * L</service_id>

=back

=cut

__PACKAGE__->set_primary_key("user_id", "service", "service_id");

=head1 RELATIONS

=head2 user

Type: belongs_to

Related object: L<PearlBee::Model::Schema::Result::Users>

=cut

__PACKAGE__->belongs_to(
  "user",
  "PearlBee::Model::Schema::Result::Users",
  { id => "user_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 oauth

Type: belongs_to

Related object: L<PearlBee::Model::Schema::Result::OAuth>

=cut

__PACKAGE__->belongs_to(
  "oauth",
  "PearlBee::Model::Schema::Result::OAuth",
  { name => "service" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2015-02-23 16:54:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GlRzlmZ9MHtXA6TCm+l1qg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
