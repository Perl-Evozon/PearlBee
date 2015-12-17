use utf8;
package PearlBee::Model::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PearlBee::Model::Schema::Result::User - User information.

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 username

  data_type: 'varchar'
  is_nullable: 0
  size: 200

=head2 password

  data_type: 'varchar'
  is_nullable: 0
  size: 128

=head2 preferred_language

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 register_date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 email

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 avatar_path

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 company

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 telephone

  data_type: 'varchar'
  is_nullable: 1
  size: 12

=head2 role

  data_type: 'varchar'
  default_value: 'author'
  is_foreign_key: 1
  is_nullable: 0
  size: 255

=head2 activation_key

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 status

  data_type: 'enum'
  extra: {list => ["active","inactive","suspended"]}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "username",
  { data_type => "varchar", is_nullable => 0, size => 200 },
  "password",
  { data_type => "varchar", is_nullable => 0, size => 128 },
  "preferred_language",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "register_date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "avatar_path",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "company",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "telephone",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "role",
  {
    data_type => "varchar",
    default_value => "author",
    is_foreign_key => 1,
    is_nullable => 0,
    size => 255,
  },
  "activation_key",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "status",
  {
    data_type => "enum",
    extra => { list => ["active", "inactive", "suspended"] },
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<email>

=over 4

=item * L</email>

=back

=cut

__PACKAGE__->add_unique_constraint("email", ["email"]);

=head2 C<username>

=over 4

=item * L</username>

=back

=cut

__PACKAGE__->add_unique_constraint("username", ["username"]);

=head1 RELATIONS

=head2 assets

Type: has_many

Related object: L<PearlBee::Model::Schema::Result::Asset>

=cut

__PACKAGE__->has_many(
  "assets",
  "PearlBee::Model::Schema::Result::Asset",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 blog_owners

Type: has_many

Related object: L<PearlBee::Model::Schema::Result::BlogOwner>

=cut

__PACKAGE__->has_many(
  "blog_owners",
  "PearlBee::Model::Schema::Result::BlogOwner",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 categories

Type: has_many

Related object: L<PearlBee::Model::Schema::Result::Category>

=cut

__PACKAGE__->has_many(
  "categories",
  "PearlBee::Model::Schema::Result::Category",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 comments

Type: has_many

Related object: L<PearlBee::Model::Schema::Result::Comment>

=cut

__PACKAGE__->has_many(
  "comments",
  "PearlBee::Model::Schema::Result::Comment",
  { "foreign.uid" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 posts

Type: has_many

Related object: L<PearlBee::Model::Schema::Result::Post>

=cut

__PACKAGE__->has_many(
  "posts",
  "PearlBee::Model::Schema::Result::Post",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 role

Type: belongs_to

Related object: L<PearlBee::Model::Schema::Result::Role>

=cut

__PACKAGE__->belongs_to(
  "role",
  "PearlBee::Model::Schema::Result::Role",
  { name => "role" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-12-17 13:13:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lKZ9twVeHAcvYJunXb+fNw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
=head

Check if the user has administration authority

=cut

__PACKAGE__->belongs_to(
  "role",
  "PearlBee::Model::Schema::Result::Role",
  { name => "role" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


sub is_admin {
  my ($self) = shift;

  return 1 if ( $self->role eq 'admin' );

  return 0;
}

=head

Check if the user has author authority

=cut

sub is_author {
  my ($self) = shift;

  return 1 if ( $self->role eq 'author' );

  return 0;
}

=head

Check if the user is active

=cut

sub is_active {
  my ($self) = shift;

  return 1 if ( $self->role eq 'active' );

  return 0;
}

=head

Check if the user is deactived

=cut

sub is_deactive {
  my ($self) = shift;

  return 1 if ( $self->role eq 'inactive' );

  return 0;
}

=head

Status changes

=cut

sub deactivate {
  my $self = shift;

  $self->update({ status => 'inactive' });
}

sub activate {
  my $self = shift;

  $self->update({ status => 'active' });
}

sub suspend {
  my $self = shift;

  $self->update({ status => 'suspended' });
}

sub allow {
  my $self = shift;
  
  # set a password for the user
  
  # welcome the user in an email

  $self->update({ status => 'inactive' });
}

1;
