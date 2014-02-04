package PearlBee::Model::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

PearlBee::Model::Schema::Result::User

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 first_name

  data_type: 'varchar'
  is_nullable: 0
  size: 300

=head2 last_name

  data_type: 'varchar'
  is_nullable: 0
  size: 300

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
  size: 300

=head2 company

  data_type: 'varchar'
  is_nullable: 1
  size: 300

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
  default_value: 'deactivated'
  extra: {list => ["deactivated","activated","suspended"]}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "first_name",
  { data_type => "varchar", is_nullable => 0, size => 300 },
  "last_name",
  { data_type => "varchar", is_nullable => 0, size => 300 },
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
  { data_type => "varchar", is_nullable => 0, size => 300 },
  "company",
  { data_type => "varchar", is_nullable => 1, size => 300 },
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
    default_value => "deactivated",
    extra => { list => ["deactivated", "activated", "suspended"] },
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("email", ["email"]);
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

=head2 setting

Type: might_have

Related object: L<PearlBee::Model::Schema::Result::Setting>

=cut

__PACKAGE__->might_have(
  "setting",
  "PearlBee::Model::Schema::Result::Setting",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2014-02-04 12:34:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qCIkJ+Ha5R5utDlemNehBA


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

  return 1 if ( $self->role eq 'activated' );

  return 0;
}

=head

Check if the user is deactived

=cut

sub is_deactive {
  my ($self) = shift;

  return 1 if ( $self->role eq 'deactivated' );

  return 0;
}

1;
