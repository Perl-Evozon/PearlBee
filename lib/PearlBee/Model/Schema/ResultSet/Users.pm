package  PearlBee::Model::Schema::ResultSet::Users;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

=head2 Search for a username case-insensitive

=cut

sub search_lc {
  my ($self, $username) = @_;
  my $schema            = $self->result_source->schema;
  
  my $lc_username = lc $username;
  return $schema->resultset('Users')->
                  search( \[ "lower(username) like '\%$lc_username\%'" ] );
}

=head1 Create user with pre-hashed password

=cut

sub create_hashed {
  my ($self, $args) = @_;
  my $schema  = $self->result_source->schema;

  my @alpha  = ( 'a' .. 'z', 'A' .. 'Z', 0 .. 9 );
  my $salt   = join '', map $alpha[ rand @alpha ], 1 .. 16;

  my $algo   = '$6$' . $salt . '$';
  my $hashed = crypt( $args->{password}, $algo );

  $schema->resultset('Users')->create({
    username       => $args->{username},
    password       => $hashed,
    email          => $args->{email},
    name           => $args->{name},
    role           => $args->{role},
    status         => $args->{status},
    activation_key => $args->{activation_key}
  });
}

1;
