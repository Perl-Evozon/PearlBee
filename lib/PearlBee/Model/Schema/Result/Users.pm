use utf8;
package PearlBee::Model::Schema::Result::Users;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PearlBee::Model::Schema::Result::Users - Users table.

=cut

use strict;
use warnings;
use Dancer2; # Pick up the default avatar
use PearlBee::Helpers::Util qw( string_to_slug );

use base 'DBIx::Class::Core';

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

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

=head2 theme

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 biography

  data_type: 'vclob'
  is_nullable: 1

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
  "biography",
  { data_type => "mediumtext", is_nullable => 0 },
  "theme",
  { data_type => "varchar", is_nullable => 0, size => 50 },
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

=head2 is_admin

Check if the user has administration authority

=cut

sub is_admin {
  my ($self) = @_;

  return 1 if ( $self->role eq 'admin' );
  return 0;
}

=head2 is_author

Check if the user has author authority

=cut

sub is_author {
  my ($self) = @_;

  return 1 if ( $self->role eq 'author' );
  return 0;
}

=head2 is_active

Check if the user is active

=cut

sub is_active {
  my ($self) = @_;

  return 1 if ( $self->role eq 'active' );
  return 0;
}

=head2 is_inactive

Check if the user is inactive

=cut

sub is_inactive {
  my ($self) = @_;

  return 1 if ( $self->role eq 'inactive' );

  return 0;
}

=head2 is_pending

Check if the user is pending

=cut

sub is_pending {
  my ($self) = @_;

  return 1 if ( $self->status eq 'pending' );

  return 0;
}

=head2 deactivate

Deactivate a user

=cut

sub deactivate {
  my ($self) = @_;

  $self->update({ status => 'inactive' });
}

=head2 activate

Activate a user

=cut

sub activate {
  my ($self) = @_;

  $self->update({ status => 'active' });
}

=head2 suspend

Suspend a user

=cut

sub suspend {
  my ($self) = @_;

  $self->update({ status => 'suspended' });
}

=head2 allow

Allow a user

=cut

sub allow {
  my ($self) = @_;
  
  # set a password for the user
  
  # welcome the user in an email

  $self->update({ status => 'inactive' });
}

=head2 avatar

Return an avatar based on the path

=cut

sub avatar {
  my ($self)       = @_;
  my $id           = $self->id;
  my $userpic_path = "userpics/userpic-${id}-100x100.png";

  if ( $self->avatar_path and
       $self->avatar_path ne '' and
       -e "public/" . $self->avatar_path ) {
    return $self->avatar_path;
  }
  if ( -e $userpic_path ) {
    return $userpic_path;
  }
  return config->{default_avatar};
}

=head2 as_hashref

Return a non-blessed version of a users database row

=cut

sub as_hashref {
  my ($self)   = @_;
  my $user_obj = {
    id             => $self->id,
    name           => $self->name,
    username       => $self->username,
    slug           => $self->slug,
    password       => $self->password,
    register_date  => $self->register_date,
    email          => $self->email,
    biography      => $self->biography,
    theme          => $self->theme,
    avatar_path    => $self->avatar_path,
    avatar         => $self->avatar,
    #company        => $self->company,
    #telephone      => $self->telephone,
    role           => $self->role,
    activation_key => $self->activation_key,
    status         => $self->status,
    is_admin       => $self->is_admin,
  };

  return $user_obj;

}

=head2 as_hashref_sanitized

Remove ID from the users database row

=cut

sub as_hashref_sanitized {
  my ($self) = @_;
  my $href   = $self->as_hashref;

  delete $href->{id};
  delete $href->{password};
  return $href;
}

=head2 slug

Get a user's "slug", this shouldn't actually be used.

=cut

sub slug {
  my ($self) = @_;

  return string_to_slug( $self->username );
}

=head2 validate

Validate a user's password

=cut

sub validate {
  my ($self, $password) = @_;

  my $hashed = crypt( $password, $self->password );

  return $self->password eq $hashed;
}

1;
