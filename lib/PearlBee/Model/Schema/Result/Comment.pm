use utf8;
package PearlBee::Model::Schema::Result::Comment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PearlBee::Model::Schema::Result::Comment

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<comment>

=cut

__PACKAGE__->table("comment");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 content

  data_type: 'text'
  is_nullable: 1

=head2 fullname

  data_type: 'varchar'
  default_value: null
  is_nullable: 1
  size: 100

=head2 email

  data_type: 'varchar'
  default_value: null
  is_nullable: 1
  size: 200

=head2 website

  data_type: 'varchar'
  default_value: null
  is_nullable: 1
  size: 255

=head2 avatar

  data_type: 'varchar'
  default_value: null
  is_nullable: 1
  size: 255

=head2 comment_date

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0

=head2 status

  data_type: 'text'
  default_value: 'pending'
  is_nullable: 1

=head2 post_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 uid

  data_type: 'integer'
  default_value: null
  is_foreign_key: 1
  is_nullable: 1

=head2 reply_to

  data_type: 'integer'
  default_value: null
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "content",
  { data_type => "text", is_nullable => 1 },
  "fullname",
  {
    data_type => "varchar",
    default_value => \"null",
    is_nullable => 1,
    size => 100,
  },
  "email",
  {
    data_type => "varchar",
    default_value => \"null",
    is_nullable => 1,
    size => 200,
  },
  "website",
  {
    data_type => "varchar",
    default_value => \"null",
    is_nullable => 1,
    size => 255,
  },
  "avatar",
  {
    data_type => "varchar",
    default_value => \"null",
    is_nullable => 1,
    size => 255,
  },
  "comment_date",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "status",
  { data_type => "text", default_value => "pending", is_nullable => 1 },
  "post_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "uid",
  {
    data_type      => "integer",
    default_value  => \"null",
    is_foreign_key => 1,
    is_nullable    => 1,
  },
  "reply_to",
  { data_type => "integer", default_value => \"null", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 post

Type: belongs_to

Related object: L<PearlBee::Model::Schema::Result::Post>

=cut

__PACKAGE__->belongs_to(
  "post",
  "PearlBee::Model::Schema::Result::Post",
  { id => "post_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 uid

Type: belongs_to

Related object: L<PearlBee::Model::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "uid",
  "PearlBee::Model::Schema::Result::User",
  { id => "uid" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-09-09 16:21:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1sqjFqOO+4E9DEBvEk578Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->load_components(qw/UTF8Columns/);
__PACKAGE__->utf8_columns(qw/content/);

sub approve {
  my ($self, $user) = @_;

  $self->update({ status => 'approved '}) if ( $self->is_authorized( $user ) );
}

sub trash {
  my ($self, $user) = @_;

  $self->update({ status => 'trash '}) if ( $self->is_authorized( $user ) );
}

sub spam {
  my ($self, $user) = @_;

  $self->update({ status => 'spam '}) if ( $self->is_authorized( $user ) );
}

sub pending {
  my ($self, $user) = @_;

  $self->update({ status => 'pending '}) if ( $self->is_authorized( $user ) );
}

=haed
Check if the user has enough authorization for modifying
=cut

sub is_authorized {
  my ($self, $user) = @_;

  my $schema     = $self->result_source->schema;
  $user          = $schema->resultset('User')->find( $user->{id} );
  my $authorized = 0;
  $authorized    = 1 if ( $user->is_admin );
  $authorized    = 1 if ( !$user->is_admin && $self->post->user_id == $user->id );

  return $authorized;
}

1;
