use utf8;
package PearlBee::Model::Schema::Result::Comment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PearlBee::Model::Schema::Result::Comment - Comment table.

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';
use DateTime;
use DateTime::Format::MySQL;
use Date::Period::Human;

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
  is_nullable: 1
  size: 100

=head2 email

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 website

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 avatar

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 comment_date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 type

  data_type: 'enum'
  default_value: 'HTML'
  is_nullable: 0

=head2 status

  data_type: 'enum'
  default_value: 'pending'
  extra: {list => ["approved","spam","pending","trash"]}
  is_nullable: 1

=head2 post_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 uid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 reply_to

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "content",
  { data_type => "text", is_nullable => 1 },
  "fullname",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "website",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "avatar",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "comment_date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "type",
  { data_type => "enum", is_nullable => 0 },
  "status",
  {
    data_type => "enum",
    default_value => "pending",
    extra => { list => ["approved", "spam", "pending", "trash"] },
    is_nullable => 1,
  },
  "post_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "uid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "reply_to",
  { data_type => "integer", is_nullable => 1 },
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
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
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
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2015-03-12 11:32:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kXOgl6BN015P4v3rssxB+g


# You can replace this text with custom code or comments, and it will be preserved on regeneration

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

sub avatar_path {

	my ($self) = @_;
        return $self->uid->avatar_path 
                if $self->uid and $self->uid->avatar_path;
        return;
}

sub comment_date_DT {

        my ($self) = @_;
        return DateTime::Format::MySQL->parse_datetime( $self->comment_date );
}

sub comment_date_human {

        my ($self) = @_;
        if ( DateTime->compare(
                $self->comment_date_DT,
                DateTime->now( time_zone => 'UTC' ) ) == -1 ) {
#                DateTime->now ) == -1 ) {
my @today_gmt = (gmtime())[5,4,3,2,1,0];
                #my $dph = Date::Period::Human->new({ lang => 'en', today_and_now => \@today_gmt });
                my $dph = Date::Period::Human->new({ lang => 'en' });
                return $dph->human_readable( $self->comment_date );
        }
        else {
                return $self->comment_date;
        }
}

1;
