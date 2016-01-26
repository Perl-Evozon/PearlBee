use utf8;
package PearlBee::Model::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PearlBee::Model::Schema::Result::User - User table.

=cut

use strict;
use warnings;
use Dancer2; # Pick up the default avatar

use base 'DBIx::Class::Core';

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
  size: 100

=head2 register_date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 email

  data_type: 'varchar'
  is_nullable: 0
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

  data_type: 'enum'
  default_value: 'author'
  extra: {list => ["author","admin"]}
  is_nullable: 0

=head2 activation_key

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 status

  data_type: 'enum'
  default_value: 'inactive'
  extra: {list => ["inactive","active","suspended","pending"]}
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
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "register_date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "email",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "avatar_path",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "company",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "telephone",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "role",
  {
    data_type => "enum",
    default_value => "author",
    extra => { list => ["author", "admin"] },
    is_nullable => 0,
  },
  "activation_key",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "status",
  {
    data_type => "enum",
    default_value => "inactive",
    extra => { list => ["inactive", "active", "suspended", "pending"] },
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


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2015-03-12 11:32:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:K9HSB67oau0IzWdJILumFg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
=head

Check if the user has administration authority

=cut

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

sub avatar {
  my $self = shift;

  return $self->avatar_path
    if $self->avatar_path and $self->avatar_path ne '';
  return config->{default_avatar};
}

sub as_hashref {
  my $self = shift;
  my $user_obj = {
    is_admin => $self->is_admin,
    role     => $self->role,
    id       => $self->id,
    username => $self->username,
    avatar   => $self->avatar,
  };

  return $user_obj;

}

1;
